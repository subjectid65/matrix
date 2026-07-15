<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Page Not Found - MLM Matrix Plan</title>
</head>
<body>
    <div class="container-fluid">
        <div class="row justify-content-center mt-5">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header bg-warning">
                        <h4 class="mb-0"><i class="fas fa-exclamation-triangle"></i> 404 - Page Not Found</h4>
                    </div>
                    <div class="card-body text-center">
                        <i class="fas fa-search fa-5x text-warning mb-3"></i>
                        <h3>The page was not found</h3>
                        <p class="text-muted">The page you are looking for doesn't exist or has been moved.</p>
                        <a href="${createLink(uri: '/')}" class="btn btn-primary mt-3">
                            <i class="fas fa-home"></i> Go to Dashboard
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>