<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title><g:layoutTitle default="MLM Matrix Plan System"/></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
    <g:layoutHead/>
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .navbar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .navbar-brand {
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        .sidebar {
            position: fixed;
            top: 56px;
            bottom: 0;
            left: 0;
            z-index: 100;
            padding: 48px 0 0;
            box-shadow: inset -1px 0 0 rgba(0, 0, 0, .1);
            background-color: #fff;
            overflow-y: auto;
        }
        .sidebar .nav-link {
            color: #333;
            padding: 12px 20px;
            border-left: 3px solid transparent;
            transition: all 0.3s;
        }
        .sidebar .nav-link:hover {
            background-color: #f5f5f5;
            border-left-color: #667eea;
        }
        .sidebar .nav-link.active {
            background-color: #eef0ff;
            color: #667eea;
            border-left-color: #667eea;
            font-weight: 600;
        }
        .sidebar .nav-link i {
            width: 24px;
            text-align: center;
            margin-right: 10px;
        }
        .main-content {
            margin-top: 56px;
            padding: 20px;
        }
        .card {
            border: none;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
            border-radius: 10px;
        }
        .card-header {
            background-color: #fff;
            border-bottom: 1px solid #eee;
            font-weight: 600;
        }
        .badge-active { background-color: #28a745; }
        .badge-pending { background-color: #ffc107; color: #333; }
        .badge-inactive { background-color: #6c757d; }
        .badge-banned { background-color: #dc3545; }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-dark navbar-expand-lg">
        <div class="container-fluid">
            <a class="navbar-brand" href="${createLink(uri: '/')}">
                <i class="fas fa-sitemap"></i> MLM Matrix Plan
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${createLink(uri: '/')}"><i class="fas fa-home"></i> Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${createLink(uri: '/member')}"><i class="fas fa-users"></i> Members</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${createLink(uri: '/matrix/config-dashboard')}"><i class="fas fa-cog"></i> Settings</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    
    <!-- Flash Messages -->
    <div class="container-fluid main-content">
        <g:if env="development" test="${flash.message}">
            <div class="alert alert-${flash.type ?: 'info'} alert-dismissible fade show" role="alert">
                ${flash.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </g:if>
        
        <!-- Page Content -->
        <g:layoutBody/>
    </div>
    
    <!-- Footer -->
    <footer class="text-center text-muted py-3 mt-5" style="background: #fff; border-top: 1px solid #eee;">
        <small>MLM Matrix Plan System &copy; ${new Date().year + 1900} | Built with Grails</small>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>