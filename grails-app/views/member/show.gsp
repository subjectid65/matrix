<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Member Details - ${member?.userId}</title>
    <style>
        .member-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .leg-bar {
            height: 30px;
            border-radius: 15px;
            overflow: hidden;
            background: #e9ecef;
            position: relative;
        }
        .leg-bar-fill {
            height: 100%;
            transition: width 0.5s ease;
        }
        .leg-left { background: linear-gradient(90deg, #007bff, #0056b3); }
        .leg-right { background: linear-gradient(90deg, #28a745, #1e7e34); }
        .matrix-cell {
            width: 100%;
            aspect-ratio: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            font-weight: bold;
            font-size: 0.8rem;
            transition: all 0.3s;
        }
        .matrix-cell.occupied {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: #667eea;
        }
        .matrix-cell.empty {
            background: #f8f9fa;
            color: #adb5bd;
        }
        .matrix-cell.self {
            background: linear-gradient(135deg, #ffd700 0%, #ffaa00 100%);
            color: #333;
            border-color: #ffd700;
            box-shadow: 0 0 15px rgba(255, 215, 0, 0.5);
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${createLink(uri: '/')}">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${createLink(uri: '/member')}">Members</a></li>
                <li class="breadcrumb-item active">${member?.userId}</li>
            </ol>
        </nav>
        
        <!-- Member Header -->
        <div class="member-header">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="mb-1">
                        <i class="fas fa-user-circle"></i> ${member?.userId}
                    </h1>
                    <h5 class="mb-2 opacity-75">${member?.fullName ?: member?.userName}</h5>
                    <div>
                        <span class="me-3"><i class="fas fa-envelope"></i> ${member?.email ?: 'N/A'}</span>
                        <span class="me-3"><i class="fas fa-phone"></i> ${member?.phoneNumber ?: 'N/A'}</span>
                        <span><i class="fas fa-calendar"></i> ${member?.joinDate ?: 'N/A'}</span>
                    </div>
                </div>
                <div class="col-md-4 text-end">
                    <g:if test="${member?.status == 'ACTIVE'}">
                        <span class="badge bg-success fs-6 px-3 py-2">ACTIVE</span>
                    </g:if>
                    <g:elseif test="${member?.status == 'PENDING'}">
                        <span class="badge bg-warning fs-6 px-3 py-2">PENDING</span>
                    </g:elseif>
                    <g:else>
                        <span class="badge bg-secondary fs-6 px-3 py-2">${member?.status}</span>
                    </g:else>
                    <div class="mt-2">
                        <a href="${createLink(uri: '/member/edit/' + member.id)}" class="btn btn-light btn-sm me-2">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                        <a href="${createLink(uri: '/member/create')}" class="btn btn-light btn-sm">
                            <i class="fas fa-plus"></i> Add Downline
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <!-- Left Column -->
            <div class="col-md-4">
                <!-- Leg Status -->
                <div class="card mb-3">
                    <div class="card-header">
                        <i class="fas fa-chart-bar"></i> Matrix Leg Status
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <div class="d-flex justify-content-between mb-1">
                                <span><i class="fas fa-arrow-left text-primary"></i> Left Leg</span>
                                <span>${member?.leftLegCount ?: 0} / ${legCapacity}</span>
                            </div>
                            <div class="leg-bar">
                                <div class="leg-bar-fill leg-left" style="width: ${(member?.leftLegCount ?: 0) / legCapacity * 100}%"></div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between mb-1">
                                <span><i class="fas fa-arrow-right text-success"></i> Right Leg</span>
                                <span>${member?.rightLegCount ?: 0} / ${legCapacity}</span>
                            </div>
                            <div class="leg-bar">
                                <div class="leg-bar-fill leg-right" style="width: ${(member?.rightLegCount ?: 0) / legCapacity * 100}%"></div>
                            </div>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between">
                            <span>Total Downlines:</span>
                            <strong>${member?.downlineCount ?: 0}</strong>
                        </div>
                        <div class="d-flex justify-content-between mt-1">
                            <span>Level:</span>
                            <strong>${member?.level ?: 0}</strong>
                        </div>
                        <div class="d-flex justify-content-between mt-1">
                            <span>Placement:</span>
                            <strong>${member?.placementPosition ?: 'ROOT'}</strong>
                        </div>
                    </div>
                </div>
                
                <!-- Sponsor Info -->
                <div class="card mb-3">
                    <div class="card-header">
                        <i class="fas fa-user-tie"></i> Sponsor Information
                    </div>
                    <div class="card-body">
                        <g:if test="${sponsor}">
                            <div class="d-flex align-items-center mb-2">
                                <div class="member-avatar me-2" style="width:35px;height:35px;font-size:0.9rem;">
                                    ${sponsor.userId?.charAt(0)?.toUpperCase()}
                                </div>
                                <div>
                                    <strong>${sponsor.userId}</strong>
                                    <br><small class="text-muted">${sponsor.fullName}</small>
                                </div>
                            </div>
                        </g:if>
                        <g:else>
                            <p class="text-muted mb-0">This is a root member (no sponsor)</p>
                        </g:else>
                    </div>
                </div>
                
                <!-- Quick Stats -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-info-circle"></i> Member Details
                    </div>
                    <div class="card-body">
                        <table class="table table-sm mb-0">
                            <tbody>
                                <tr>
                                    <td><strong>User ID:</strong></td>
                                    <td>${member?.userId}</td>
                                </tr>
                                <tr>
                                    <td><strong>Username:</strong></td>
                                    <td>${member?.userName}</td>
                                </tr>
                                <tr>
                                    <td><strong>Full Name:</strong></td>
                                    <td>${member?.fullName ?: '-'}</td>
                                </tr>
                                <tr>
                                    <td><strong>Email:</strong></td>
                                    <td>${member?.email ?: '-'}</td>
                                </tr>
                                <tr>
                                    <td><strong>Phone:</strong></td>
                                    <td>${member?.phoneNumber ?: '-'}</td>
                                </tr>
                                <tr>
                                    <td><strong>Join Date:</strong></td>
                                    <td>${member?.joinDate ?: '-'}</td>
                                </tr>
                                <tr>
                                    <td><strong>Matrix Size:</strong></td>
                                    <td>${member?.matrixWidth ?: 3} x ${member?.matrixHeight ?: 3}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Right Column -->
            <div class="col-md-8">
                <!-- Matrix Visualization -->
                <div class="card mb-3">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="fas fa-th"></i> Matrix Visualization (${matrixViz?.config?.matrixWidth ?: 3} x ${matrixViz?.config?.matrixHeight ?: 3})</span>
                        <a href="${createLink(uri: '/matrix/visualization/' + member.userId)}" class="btn btn-sm btn-outline-primary">
                            <i class="fas fa-expand"></i> Full View
                        </a>
                    </div>
                    <div class="card-body">
                        <div class="row g-2 justify-content-center">
                            <g:each var="row" in="${matrixViz?.grid ?: []}">
                                <div class="col-12">
                                    <div class="d-flex g-2 justify-content-center">
                                        <g:each var="cell" in="${row}">
                                            <div class="matrix-cell ${cell == member?.userId ? 'self' : (cell ? 'occupied' : 'empty')}" 
                                                 style="width: 80px; height: 80px;">
                                                ${cell ?: '-'}
                                            </div>
                                        </g:each>
                                    </div>
                                </div>
                            </g:each>
                        </div>
                        <div class="text-center mt-3 text-muted small">
                            <span class="me-3"><span class="badge" style="background:#ffd700;color:#333;">You</span> Your Position</span>
                            <span class="me-3"><span class="badge" style="background:linear-gradient(135deg, #667eea, #764ba2);color:white;">member</span> Occupied</span>
                            <span><span class="badge bg-light text-muted">-</span> Empty</span>
                        </div>
                    </div>
                </div>
                
                <!-- Direct Downlines -->
                <div class="card mb-3">
                    <div class="card-header">
                        <i class="fas fa-sitemap"></i> Direct Downlines (${member?.downlineCount ?: 0})
                    </div>
                    <div class="card-body">
                        <g:if test="${member?.leftChildren?.size() > 0 || member?.rightChildren?.size() > 0}">
                            <div class="row">
                                <div class="col-md-6">
                                    <h6 class="text-primary"><i class="fas fa-arrow-left"></i> Left Children (${member?.leftChildren?.size()})</h6>
                                    <g:each var="child" in="${member?.leftChildren ?: []}">
                                        <div class="d-flex align-items-center mb-2 p-2 border rounded">
                                            <div class="member-avatar me-2" style="width:30px;height:30px;font-size:0.8rem;">
                                                ${child.userId?.charAt(0)?.toUpperCase()}
                                            </div>
                                            <div>
                                                <a href="${createLink(uri: '/member/show/' + child.id)}" class="text-decoration-none">
                                                    <strong>${child.userId}</strong>
                                                </a>
                                                <br><small class="text-muted">${child.fullName ?: child.userName}</small>
                                            </div>
                                        </div>
                                    </g:each>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="text-success"><i class="fas fa-arrow-right"></i> Right Children (${member?.rightChildren?.size()})</h6>
                                    <g:each var="child" in="${member?.rightChildren ?: []}">
                                        <div class="d-flex align-items-center mb-2 p-2 border rounded">
                                            <div class="member-avatar me-2" style="width:30px;height:30px;font-size:0.8rem;background:linear-gradient(135deg, #28a745, #1e7e34);color:white;">
                                                ${child.userId?.charAt(0)?.toUpperCase()}
                                            </div>
                                            <div>
                                                <a href="${createLink(uri: '/member/show/' + child.id)}" class="text-decoration-none">
                                                    <strong>${child.userId}</strong>
                                                </a>
                                                <br><small class="text-muted">${child.fullName ?: child.userName}</small>
                                            </div>
                                        </div>
                                    </g:each>
                                </div>
                            </div>
                        </g:if>
                        <g:else>
                            <p class="text-muted text-center mb-0">No direct downlines yet</p>
                        </g:else>
                    </div>
                </div>
                
                <!-- Commission Eligibility -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-coins"></i> Commission Eligibility
                    </div>
                    <div class="card-body">
                        <table class="table table-sm mb-0">
                            <tbody>
                                <tr>
                                    <td><strong>Left Commission Rate:</strong></td>
                                    <td>${commissionInfo?.leftCommissionRate ?: 50}%</td>
                                </tr>
                                <tr>
                                    <td><strong>Right Commission Rate:</strong></td>
                                    <td>${commissionInfo?.rightCommissionRate ?: 50}%</td>
                                </tr>
                                <tr>
                                    <td><strong>Matching Bonus:</strong></td>
                                    <td>${commissionInfo?.matchingBonusRate ?: 0}%</td>
                                </tr>
                                <tr>
                                    <td><strong>Pool Bonus:</strong></td>
                                    <td>${commissionInfo?.poolBonusRate ?: 0}%</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>