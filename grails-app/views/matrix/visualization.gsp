<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Matrix Visualization - ${member?.userId}</title>
    <style>
        .matrix-container {
            display: flex;
            justify-content: center;
            padding: 20px;
        }
        .matrix-grid {
            display: grid;
            gap: 10px;
            max-width: 800px;
        }
        .matrix-cell {
            width: 100%;
            aspect-ratio: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            font-weight: bold;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            min-height: 80px;
        }
        .matrix-cell:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        .matrix-cell.root {
            background: linear-gradient(135deg, #ffd700 0%, #ffaa00 100%);
            color: #333;
            border: 3px solid #ff8c00;
        }
        .matrix-cell.occupied {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: 2px solid #5a67d8;
        }
        .matrix-cell.empty {
            background: #f8f9fa;
            color: #adb5bd;
            border: 2px dashed #dee2e6;
        }
        .matrix-cell .cell-label {
            font-size: 0.75rem;
            opacity: 0.8;
        }
        .matrix-cell .cell-value {
            font-size: 0.9rem;
        }
        .leg-stat {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 15px;
        }
        .leg-left-stat {
            background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
            border-left: 4px solid #1976d2;
        }
        .leg-right-stat {
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
            border-left: 4px solid #388e3c;
        }
        .progress-thick {
            height: 20px;
            border-radius: 10px;
        }
        .progress-thick .progress-bar {
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${createLink(uri: '/')}">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${createLink(uri: '/member')}">Members</a></li>
                <li class="breadcrumb-item"><a href="${createLink(uri: '/member/show/' + member.id)}">${member?.userId}</a></li>
                <li class="breadcrumb-item active">Matrix View</li>
            </ol>
        </nav>
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-th"></i> Matrix Visualization - ${member?.userId}</h2>
            <a href="${createLink(uri: '/member/show/' + member.id)}" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left"></i> Back to Member
            </a>
        </div>
        
        <!-- Leg Statistics -->
        <div class="row mb-4">
            <div class="col-md-6">
                <%
                    def leftCount = member?.leftLegCount ?: 0
                    def leftPercent = ((leftCount as Double) / (legCapacity ?: 1) * 100)
                %>
                <div class="leg-stat leg-left-stat">
                    <h5><i class="fas fa-arrow-left text-primary"></i> Left Leg</h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Members: <strong><%= leftCount %></strong></span>
                        <span>Capacity: <strong>${legCapacity}</strong></span>
                    </div>
                    <div class="progress progress-thick">
                        <div class="progress-bar bg-primary" role="progressbar" 
                              style="width: <%= leftPercent %>%">
                        </div>
                    </div>
                    <small class="text-muted"><%= String.format("%.1f", leftPercent) %>% filled</small>
                </div>
            </div>
            <div class="col-md-6">
                <%
                    def rightCount = member?.rightLegCount ?: 0
                    def rightPercent = ((rightCount as Double) / (legCapacity ?: 1) * 100)
                %>
                <div class="leg-stat leg-right-stat">
                    <h5><i class="fas fa-arrow-right text-success"></i> Right Leg</h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Members: <strong><%= rightCount %></strong></span>
                        <span>Capacity: <strong>${legCapacity}</strong></span>
                    </div>
                    <div class="progress progress-thick">
                        <div class="progress-bar bg-success" role="progressbar" 
                              style="width: <%= rightPercent %>%">
                        </div>
                    </div>
                    <small class="text-muted"><%= String.format("%.1f", rightPercent) %>% filled</small>
                </div>
            </div>
        </div>
        
        <!-- Matrix Grid -->
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="fas fa-sitemap"></i> Matrix Grid (${config?.matrixWidth ?: 3} x ${config?.matrixHeight ?: 3})</span>
                <div>
                    <span class="badge bg-info me-2">Width: ${config?.matrixWidth ?: 3}</span>
                    <span class="badge bg-success me-2">Height: ${config?.matrixHeight ?: 3}</span>
                    <span class="badge bg-warning">Slots/Leg: ${legCapacity}</span>
                </div>
            </div>
            <div class="card-body">
                <div class="matrix-container">
                    <div class="matrix-grid" style="grid-template-columns: repeat(${config?.matrixWidth ?: 3}, 1fr);">
                        <%
                            def grid = matrixViz?.grid
                            def gridRows = grid?.size() ?: 0
                            def gridCols = gridRows > 0 ? grid[0]?.size() ?: 0 : 0
                        %>
                        <g:each var="row" in="${0..<gridRows}">
                            <g:each var="colIdx" in="${0..<gridCols}">
                                <div class="matrix-cell ${grid[row][colIdx] == member?.userId ? 'root' : (grid[row][colIdx] ? 'occupied' : 'empty')}">
                                    <span class="cell-label">[${row + 1},${colIdx + 1}]</span>
                                    <span class="cell-value">${grid[row][colIdx] ?: '-'}</span>
                                </div>
                            </g:each>
                        </g:each>
                    </div>
                </div>
                <div class="text-center mt-3">
                    <span class="badge" style="background:linear-gradient(135deg, #ffd700, #ffaa00);color:#333;">★</span> Root Member
                    <span class="badge" style="background:linear-gradient(135deg, #667eea, #764ba2);color:white;margin-left:10px;">■</span> Occupied
                    <span class="badge bg-light text-dark border border-muted border-dashed" style="margin-left:10px;">-</span> Empty
                </div>
            </div>
        </div>
        
        <!-- Downline Tree -->
        <div class="card">
            <div class="card-header">
                <i class="fas fa-project-diagram"></i> Downline Structure
            </div>
            <div class="card-body">
                <g:if test="${genealogyTree}">
                    <g:each var="child" in="${member?.leftChildren ?: []}" status="i">
                        <div class="alert alert-primary d-inline-block me-2 mb-2" style="min-width:150px;">
                            <strong>L${i+1}:</strong> <a href="${createLink(uri: '/member/show/' + child.id)}">${child.userId}</a>
                            <br><small>Left: ${child.leftLegCount}, Right: ${child.rightLegCount}</small>
                        </div>
                    </g:each>
                    <g:each var="child" in="${member?.rightChildren ?: []}" status="i">
                        <div class="alert alert-success d-inline-block me-2 mb-2" style="min-width:150px;">
                            <strong>R${i+1}:</strong> <a href="${createLink(uri: '/member/show/' + child.id)}">${child.userId}</a>
                            <br><small>Left: ${child.leftLegCount}, Right: ${child.rightLegCount}</small>
                        </div>
                    </g:each>
                </g:if>
                <g:else>
                    <p class="text-muted text-center">No downlines yet</p>
                </g:else>
            </div>
        </div>
    </div>
</body>
</html>