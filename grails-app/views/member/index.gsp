<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.math.BigDecimal" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Member Management - MLM Matrix Plan</title>
    <style>
        .filter-bar {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
        }
        .member-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-users"></i> Member Management</h2>
            <div>
                <a href="${createLink(uri: '/member/create')}" class="btn btn-primary">
                    <i class="fas fa-plus"></i> Add New Member
                </a>
                <a href="${createLink(uri: '/matrix/quick-placement')}" class="btn btn-success">
                    <i class="fas fa-bolt"></i> Quick Placement
                </a>
            </div>
        </div>
        
        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-2">
                <div class="card text-center bg-primary text-white">
                    <div class="card-body">
                        <h3>${memberStats?.totalMembers ?: 0}</h3>
                        <small>Total</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card text-center bg-success text-white">
                    <div class="card-body">
                        <h3>${memberStats?.activeMembers ?: 0}</h3>
                        <small>Active</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card text-center bg-warning text-dark">
                    <div class="card-body">
                        <h3>${memberStats?.pendingMembers ?: 0}</h3>
                        <small>Pending</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card text-center bg-secondary text-white">
                    <div class="card-body">
                        <h3>${memberStats?.inactiveMembers ?: 0}</h3>
                        <small>Inactive</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card text-center bg-info text-white">
                    <div class="card-body">
                        <h3>${memberStats?.rootMembers ?: 0}</h3>
                        <small>Root</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card text-center bg-danger text-white">
                    <div class="card-body">
                        <h3>${memberStats?.bannedMembers ?: 0}</h3>
                        <small>Banned</small>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Filter Bar -->
        <div class="filter-bar">
            <form method="GET" action="${createLink(uri: '/member')}" class="row g-3">
                <div class="col-md-3">
                    <input type="text" name="search" class="form-control" placeholder="Search by ID, name, email..." value="${params.search ?: ''}"/>
                </div>
                <div class="col-md-2">
                    <select name="status" class="form-select">
                        <option value="">All Status</option>
                        <option value="ACTIVE" ${params.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                        <option value="PENDING" ${params.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="INACTIVE" ${params.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                        <option value="BANNED" ${params.status == 'BANNED' ? 'selected' : ''}>Banned</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <input type="text" name="sponsorId" class="form-control" placeholder="Sponsor ID" value="${params.sponsorId ?: ''}"/>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search"></i> Search</button>
                </div>
                <div class="col-md-3">
                    <a href="${createLink(uri: '/member')}" class="btn btn-outline-secondary w-100"><i class="fas fa-redo"></i> Reset</a>
                </div>
            </form>
        </div>
        
        <!-- Members Table -->
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>User ID</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Sponsor</th>
                                <th>Position</th>
                                <th>Left/Right</th>
                                <th>Level</th>
                                <th>Status</th>
                                <th>Joined</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <g:each in="${members}" var="m">
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="member-avatar">${m.userId?.charAt(0)?.toUpperCase()}</div>
                                            <strong>${m.userId}</strong>
                                        </div>
                                    </td>
                                    <td>${m.fullName ?: m.userName}</td>
                                    <td>${m.email ?: '-'}</td>
                                    <td><code>${m.sponsorId ?: 'N/A'}</code></td>
                                    <td><span class="badge bg-info">${m.placementPosition ?: 'ROOT'}</span></td>
                                    <td>
                                        <span class="text-primary">${m.leftLegCount ?: 0}</span> / 
                                        <span class="text-success">${m.rightLegCount ?: 0}</span>
                                    </td>
                                    <td>${m.level ?: 0}</td>
                                    <td>
                                        <g:if test="${m.status == 'ACTIVE'}">
                                            <span class="badge badge-active">Active</span>
                                        </g:if>
                                        <g:elseif test="${m.status == 'PENDING'}">
                                            <span class="badge badge-pending">Pending</span>
                                        </g:elseif>
                                        <g:elseif test="${m.status == 'INACTIVE'}">
                                            <span class="badge badge-inactive">Inactive</span>
                                        </g:elseif>
                                        <g:else>
                                            <span class="badge badge-banned">Banned</span>
                                        </g:else>
                                    </td>
                                    <td>${m.joinDate ?: '-'}</td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <a href="${createLink(uri: '/member/show/' + m.id)}" class="btn btn-outline-primary" title="View">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="${createLink(uri: '/member/edit/' + m.id)}" class="btn btn-outline-secondary" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <a href="${createLink(uri: '/matrix/visualization/' + m.userId)}" class="btn btn-outline-info" title="Matrix View">
                                                <i class="fas fa-th"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </g:each>
                        </tbody>
                    </table>
                </div>
                
                <g:if test="${!members || members.size() == 0}">
                    <div class="text-center py-5 text-muted">
                        <i class="fas fa-users fa-3x mb-3"></i>
                        <h5>No members found</h5>
                        <p>Add your first member to get started with the matrix plan.</p>
                        <a href="${createLink(uri: '/member/create')}" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Add First Member
                        </a>
                    </div>
                </g:if>
                
                <!-- Pagination -->
                <g:if test="${totalPages > 1}">
                    <nav class="mt-3">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${createLink(uri: '/member')}?page=${currentPage - 1}&search=${params.search ?: ''}">Previous</a>
                            </li>
                            <g:each var="i" in="${(1..Math.min(totalPages ?: 1, 20))}">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="${createLink(uri: '/member')}?page=${i}&search=${params.search ?: ''}">${i}</a>
                                </li>
                            </g:each>
                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${createLink(uri: '/member')}?page=${currentPage + 1}&search=${params.search ?: ''}">Next</a>
                            </li>
                        </ul>
                    </nav>
                </g:if>
            </div>
        </div>
    </div>
</body>
</html>