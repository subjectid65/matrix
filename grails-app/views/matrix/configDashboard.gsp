<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Matrix Configuration - MLM Matrix Plan</title>
</head>
<body>
    <div class="container-fluid">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${createLink(uri: '/')}">Dashboard</a></li>
                <li class="breadcrumb-item active">Matrix Configuration</li>
            </ol>
        </nav>
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-cog"></i> Matrix Configuration</h2>
            <a href="${createLink(uri: '/matrix/create-config')}" class="btn btn-primary">
                <i class="fas fa-plus"></i> New Configuration
            </a>
        </div>
        
        <!-- Statistics -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card text-center bg-primary text-white">
                    <div class="card-body">
                        <h3>${stats?.totalMembers ?: 0}</h3>
                        <small>Total Members</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center bg-success text-white">
                    <div class="card-body">
                        <h3>${stats?.activeMembers ?: 0}</h3>
                        <small>Active</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center bg-info text-white">
                    <div class="card-body">
                        <h3>${configs?.size() ?: 0}</h3>
                        <small>Configurations</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center bg-warning text-dark">
                    <div class="card-body">
                        <h3>${stats?.maxLevel ?: 0}</h3>
                        <small>Max Depth</small>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Configurations Table -->
        <div class="card">
            <div class="card-header">
                <i class="fas fa-database"></i> Matrix Configurations
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>Name</th>
                                <th>Width</th>
                                <th>Height</th>
                                <th>Slots/Leg</th>
                                <th>Left %</th>
                                <th>Right %</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <g:each in="${configs}" var="cfg">
                                <tr>
                                    <td><strong>${cfg.configName}</strong></td>
                                    <td>${cfg.matrixWidth}</td>
                                    <td>${cfg.matrixHeight}</td>
                                    <td>${(cfg.matrixWidth - 1) * cfg.matrixHeight / 2}</td>
                                    <td>${cfg.leftCommissionRate}%</td>
                                    <td>${cfg.rightCommissionRate}%</td>
                                    <td>
                                        <g:if test="${cfg.status == 'ACTIVE'}">
                                            <span class="badge bg-success">Active</span>
                                        </g:if>
                                        <g:else>
                                            <span class="badge bg-secondary">Inactive</span>
                                        </g:else>
                                    </td>
                                    <td>${cfg.createdAt?.format('yyyy-MM-dd')}</td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <g:if test="${cfg.status != 'ACTIVE'}">
                                                <a href="${createLink(uri: '/matrix/set-default/' + cfg.id)}" 
                                                   class="btn btn-outline-info" title="Activate">
                                                    <i class="fas fa-check"></i>
                                                </a>
                                            </g:if>
                                            <a href="${createLink(uri: '/matrix/edit-config/' + cfg.id)}" 
                                               class="btn btn-outline-secondary" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <g:if test="${cfg.status != 'ACTIVE'}">
                                                <a href="${createLink(uri: '/matrix/delete-config/' + cfg.id)}" 
                                                   class="btn btn-outline-danger" title="Delete"
                                                   onclick="return confirm('Delete this configuration?')">
                                                    <i class="fas fa-trash"></i>
                                                </a>
                                            </g:if>
                                        </div>
                                    </td>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>
                </div>
                
                <g:if test="${!configs || configs.size() == 0}">
                    <div class="text-center py-4 text-muted">
                        <i class="fas fa-cog fa-2x mb-2"></i>
                        <p>No configurations yet. Create your first matrix configuration.</p>
                    </div>
                </g:if>
            </div>
        </div>
        
        <!-- Templates -->
        <div class="card mt-4">
            <div class="card-header">
                <i class="fas fa-clone"></i> Quick Templates
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3 mb-2">
                        <div class="card template-card h-100">
                            <div class="card-body text-center">
                                <h6>Small</h6>
                                <p class="text-muted mb-1">2 x 3</p>
                                <p class="mb-2">2 slots/leg</p>
                                <button class="btn btn-sm btn-outline-primary use-template" 
                                        data-width="2" data-height="3">Use</button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-2">
                        <div class="card template-card h-100">
                            <div class="card-body text-center">
                                <h6>Medium</h6>
                                <p class="text-muted mb-1">3 x 3</p>
                                <p class="mb-2">4 slots/leg</p>
                                <button class="btn btn-sm btn-outline-primary use-template" 
                                        data-width="3" data-height="3">Use</button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-2">
                        <div class="card template-card h-100">
                            <div class="card-body text-center">
                                <h6>Large</h6>
                                <p class="text-muted mb-1">4 x 3</p>
                                <p class="mb-2">6 slots/leg</p>
                                <button class="btn btn-sm btn-outline-primary use-template" 
                                        data-width="4" data-height="3">Use</button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-2">
                        <div class="card template-card h-100">
                            <div class="card-body text-center">
                                <h6>XL</h6>
                                <p class="text-muted mb-1">5 x 4</p>
                                <p class="mb-2">16 slots/leg</p>
                                <button class="btn btn-sm btn-outline-primary use-template" 
                                        data-width="5" data-height="4">Use</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        document.querySelectorAll('.use-template').forEach(btn => {
            btn.addEventListener('click', function() {
                window.location.href = '${createLink(uri: '/matrix/create-config')}';
            });
        });
    </script>
</body>
</html>