public class PullRequest {
    public String id;
    public PullRequestReviewReport report;
    public String last_review_result;
    
    public class PullRequestReviewReport {
        Id record;
        PullRequestMetrics metrics;
    }

    public class PullRequestMetrics {
        Long violation_count;
    }
    
}