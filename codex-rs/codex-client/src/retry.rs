use crate::error::TransportError;
use crate::request::Request;
use rand::Rng;
use serde_json::Value;
use std::future::Future;
use std::time::Duration;
use tokio::time::sleep;

#[derive(Debug, Clone)]
pub struct RetryPolicy {
    pub max_attempts: u64,
    pub base_delay: Duration,
    pub retry_on: RetryOn,
}

#[derive(Debug, Clone)]
pub struct RetryOn {
    pub retry_429: bool,
    pub retry_5xx: bool,
    pub retry_transport: bool,
}

impl RetryOn {
    pub fn should_retry(&self, err: &TransportError, attempt: u64, max_attempts: u64) -> bool {
        if attempt >= max_attempts {
            return false;
        }
        match err {
            TransportError::Http { status, body, .. } => {
                if *status == http::StatusCode::TOO_MANY_REQUESTS {
                    self.retry_429 && !body.as_deref().is_some_and(is_non_retryable_429_body)
                } else {
                    self.retry_5xx && status.is_server_error()
                }
            }
            TransportError::Timeout | TransportError::Network(_) => self.retry_transport,
            _ => false,
        }
    }
}

fn is_non_retryable_429_body(body: &str) -> bool {
    let Ok(value) = serde_json::from_str::<Value>(body) else {
        return body.contains("usage_limit_reached")
            || body.contains("usage_not_included")
            || body.contains("insufficient_quota");
    };

    let Some(error) = value.get("error") else {
        return false;
    };

    let error_type = error
        .get("type")
        .and_then(Value::as_str)
        .or_else(|| error.get("error_type").and_then(Value::as_str));
    let code = error.get("code").and_then(Value::as_str);

    matches!(
        error_type,
        Some("usage_limit_reached" | "usage_not_included")
    ) || matches!(code, Some("insufficient_quota"))
}

pub fn backoff(base: Duration, attempt: u64) -> Duration {
    if attempt == 0 {
        return base;
    }
    let exp = 2u64.saturating_pow(attempt as u32 - 1);
    let millis = base.as_millis() as u64;
    let raw = millis.saturating_mul(exp);
    let jitter: f64 = rand::rng().random_range(0.9..1.1);
    Duration::from_millis((raw as f64 * jitter) as u64)
}

pub async fn run_with_retry<T, F, Fut>(
    policy: RetryPolicy,
    mut make_req: impl FnMut() -> Request,
    op: F,
) -> Result<T, TransportError>
where
    F: Fn(Request, u64) -> Fut,
    Fut: Future<Output = Result<T, TransportError>>,
{
    for attempt in 0..=policy.max_attempts {
        let req = make_req();
        match op(req, attempt).await {
            Ok(resp) => return Ok(resp),
            Err(err)
                if policy
                    .retry_on
                    .should_retry(&err, attempt, policy.max_attempts) =>
            {
                sleep(backoff(policy.base_delay, attempt + 1)).await;
            }
            Err(err) => return Err(err),
        }
    }
    Err(TransportError::RetryLimit)
}

#[cfg(test)]
mod tests {
    use super::*;
    use http::StatusCode;

    #[test]
    fn should_retry_retries_429_rate_limits() {
        let retry_on = RetryOn {
            retry_429: true,
            retry_5xx: false,
            retry_transport: false,
        };
        let err = TransportError::Http {
            status: StatusCode::TOO_MANY_REQUESTS,
            url: None,
            headers: None,
            body: Some(r#"{"error":{"type":"rate_limit_exceeded"}}"#.to_string()),
        };

        assert!(retry_on.should_retry(&err, 0, 1));
    }

    #[test]
    fn should_retry_does_not_retry_429_usage_limit_reached() {
        let retry_on = RetryOn {
            retry_429: true,
            retry_5xx: false,
            retry_transport: false,
        };
        let err = TransportError::Http {
            status: StatusCode::TOO_MANY_REQUESTS,
            url: None,
            headers: None,
            body: Some(r#"{"error":{"type":"usage_limit_reached"}}"#.to_string()),
        };

        assert!(!retry_on.should_retry(&err, 0, 1));
    }

    #[test]
    fn should_retry_does_not_retry_429_when_flag_disabled() {
        let retry_on = RetryOn {
            retry_429: false,
            retry_5xx: false,
            retry_transport: false,
        };
        let err = TransportError::Http {
            status: StatusCode::TOO_MANY_REQUESTS,
            url: None,
            headers: None,
            body: Some(r#"{"error":{"type":"rate_limit_exceeded"}}"#.to_string()),
        };

        assert!(!retry_on.should_retry(&err, 0, 1));
    }

    #[test]
    fn should_retry_returns_false_after_max_attempts() {
        let retry_on = RetryOn {
            retry_429: true,
            retry_5xx: true,
            retry_transport: true,
        };
        let err = TransportError::Http {
            status: StatusCode::TOO_MANY_REQUESTS,
            url: None,
            headers: None,
            body: Some(r#"{"error":{"type":"rate_limit_exceeded"}}"#.to_string()),
        };

        assert!(!retry_on.should_retry(&err, 1, 1));
    }
}
