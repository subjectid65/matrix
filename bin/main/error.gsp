<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Error - MLM Matrix Plan</title>
</head>
<body>
    <div class="container-fluid">
        <div class="row justify-content-center mt-5">
            <div class="col-md-6">
                <div class="card border-danger">
                    <div class="card-header bg-danger text-white">
                        <h4 class="mb-0"><i class="fas fa-exclamation-triangle"></i> System Error</h4>
                    </div>
                    <div class="card-body text-center">
                        <i class="fas fa-exclamation-circle fa-5x text-danger mb-3"></i>
                        <h3>An error occurred</h3>
                        <p class="text-muted">Something went wrong. Please try again later.</p>
                        <g:if test="${exception}">
                            <div class="alert alert-danger text-start">
                                <pre class="mb-0">${exception?.message}</pre>
                            </div>
                        </g:if>
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