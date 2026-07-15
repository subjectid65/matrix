<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>MLM Matrix Plan - Dashboard</title>
    <style>
        .dashboard-hero {
            text-align: center;
            padding: 40px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        .dashboard-hero h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        .dashboard-hero p {
            font-size: 1.2rem;
            opacity: 0.9;
        }
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-card .number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #667eea;
        }
        .stat-card .label {
            color: #666;
            margin-top: 10px;
            font-size: 0.9rem;
        }
        .action-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 15px;
            transition: all 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
        }
        .action-card:hover {
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            color: #667eea;
        }
        .action-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        .icon-blue { background: #e3f2fd; color: #1976d2; }
        .icon-green { background: #e8f5e9; color: #388e3c; }
        .icon-purple { background: #f3e5f5; color: #7b1fa2; }
        .icon-orange { background: #fff3e0; color: #f57c00; }
    </style>
</head>
<body>
    <div class="container-fluid" style="padding: 20px;">
        <div class="dashboard-hero">
            <h1>MLM Matrix Plan System</h1>
            <p>Multi-Level Marketing Management with Matrix Placement</p>
        </div>
        
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="number">${stats?.totalMembers ?: 0}</div>
                    <div class="label">Total Members</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="number">${stats?.activeMembers ?: 0}</div>
                    <div class="label">Active Members</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="number">${stats?.pendingMembers ?: 0}</div>
                    <div class="label">Pending Members</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="number">${stats?.maxLevel ?: 0}</div>
                    <div class="label">Max Depth</div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <h3>Quick Actions</h3>
                <a href="${createLink(uri: '/member/create')}" class="action-card">
                    <div class="action-icon icon-blue">+</div>
                    <div>
                        <h5 style="margin: 0;">Add New Member</h5>
                        <small class="text-muted">Register a new member in the matrix</small>
                    </div>
                </a>
                <a href="${createLink(uri: '/matrix/quick-placement')}" class="action-card">
                    <div class="action-icon icon-green">⚡</div>
                    <div>
                        <h5 style="margin: 0;">Quick Placement</h5>
                        <small class="text-muted">Fast member placement with auto-positioning</small>
                    </div>
                </a>
                <a href="${createLink(uri: '/member')}" class="action-card">
                    <div class="action-icon icon-purple">👥</div>
                    <div>
                        <h5 style="margin: 0;">View All Members</h5>
                        <small class="text-muted">Browse and manage all registered members</small>
                    </div>
                </a>
            </div>
            <div class="col-md-6">
                <h3>Matrix Configuration</h3>
                <a href="${createLink(uri: '/matrix/config-dashboard')}" class="action-card">
                    <div class="action-icon icon-orange">⚙️</div>
                    <div>
                        <h5 style="margin: 0;">Manage Configurations</h5>
                        <small class="text-muted">Configure matrix dimensions and commissions</small>
                    </div>
                </a>
                <div class="card mt-3">
                    <div class="card-header">Current Matrix Settings</div>
                    <div class="card-body">
                        <table class="table table-sm">
                            <tbody>
                                <tr>
                                    <td><strong>Width:</strong></td>
                                    <td>${matrixConfigs?.first()?.matrixWidth ?: 3}</td>
                                </tr>
                                <tr>
                                    <td><strong>Height:</strong></td>
                                    <td>${matrixConfigs?.first()?.matrixHeight ?: 3}</td>
                                </tr>
                                <tr>
                                    <td><strong>Left Commission:</strong></td>
                                    <td>${matrixConfigs?.first()?.leftCommissionRate ?: 50}%</td>
                                </tr>
                                <tr>
                                    <td><strong>Right Commission:</strong></td>
                                    <td>${matrixConfigs?.first()?.rightCommissionRate ?: 50}%</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-12">
                <h3>Recent Members</h3>
                <div class="card">
                    <div class="card-body">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>User ID</th>
                                    <th>Name</th>
                                    <th>Sponsor</th>
                                    <th>Position</th>
                                    <th>Status</th>
                                    <th>Joined</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <g:if test="${recentMembers?.size() > 0}">
                                    <g:each in="${recentMembers}" var="m" status="i">
                                        <tr>
                                            <td><strong>${m.userId}</strong></td>
                                            <td>${m.fullName}</td>
                                            <td>${m.sponsorId ?: 'N/A'}</td>
                                            <td><span class="badge bg-info">${m.placementPosition ?: 'ROOT'}</span></td>
                                            <td>
                                                <g:switch value="${m.status}">
                                                    <g:when test="${m.status == 'ACTIVE'}">
                                                        <span class="badge bg-success">Active</span>
                                                    </g:when>
                                                    <g:when test="${m.status == 'PENDING'}">
                                                        <span class="badge bg-warning">Pending</span>
                                                    </g:when>
                                                    <g:otherwise>
                                                        <span class="badge bg-secondary">${m.status}</span>
                                                    </g:otherwise>
                                                </g:switch>
                                            </td>
                                            <td>${m.joinDate?: ''}</td>
                                            <td>
                                                <a href="${createLink(uri: '/member/show/' + m.id)}" class="btn btn-sm btn-outline-primary">View</a>
                                            </td>
                                        </tr>
                                    </g:each>
                                </g:if>
                                <g:else>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted">No members yet. Add your first member to get started!</td>
                                    </tr>
                                </g:else>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>