<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Edit Matrix Configuration</title>
</head>
<body>
    <div class="container-fluid">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${createLink(uri: '/')}">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${createLink(uri: '/matrix/config-dashboard')}">Configurations</a></li>
                <li class="breadcrumb-item active">Edit: ${matrixConfig?.configName}</li>
            </ol>
        </nav>
        
        <div class="row">
            <div class="col-lg-8 mx-auto">
                <div class="card">
                    <div class="card-header bg-warning text-dark">
                        <h5 class="mb-0"><i class="fas fa-edit"></i> Edit: ${matrixConfig?.configName}</h5>
                    </div>
                    <div class="card-body">
                        <g:if test="${matrixConfig?.hasErrors() && matrixConfig?.errors?.allErrors}">
                            <div class="alert alert-danger">
                                <ul class="mb-0">
                                    <g:each var="err" in="${matrixConfig?.errors?.allErrors}">
                                        <li>${err?.defaultMessage}</li>
                                    </g:each>
                                </ul>
                            </div>
                        </g:if>
                        
                        <form action="${createLink(uri: '/matrix/update-config/' + matrixConfig.id)}" method="POST">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="configName" class="form-label">Configuration Name</label>
                                    <input type="text" class="form-control" id="configName" name="configName" 
                                           value="${matrixConfig?.configName ?: ''}" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="status" class="form-label">Status</label>
                                    <select class="form-select" id="status" name="status">
                                        <option value="ACTIVE" ${matrixConfig?.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                                        <option value="INACTIVE" ${matrixConfig?.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label for="matrixWidth" class="form-label">Matrix Width</label>
                                    <input type="number" class="form-control" id="matrixWidth" name="matrixWidth" 
                                           value="${matrixConfig?.matrixWidth ?: 3}" min="2" max="10" required>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label for="matrixHeight" class="form-label">Matrix Height</label>
                                    <input type="number" class="form-control" id="matrixHeight" name="matrixHeight" 
                                           value="${matrixConfig?.matrixHeight ?: 3}" min="2" max="20" required>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label for="maxLevels" class="form-label">Max Levels</label>
                                    <input type="number" class="form-control" id="maxLevels" name="maxLevels" 
                                           value="${matrixConfig?.maxLevels ?: 50}" min="1">
                                </div>
                            </div>
                            
                            <hr>
                            <h6><i class="fas fa-coins"></i> Commission Rates (%)</h6>
                            
                            <div class="row">
                                <div class="col-md-3 mb-3">
                                    <label for="leftCommissionRate" class="form-label">Left Commission</label>
                                    <input type="number" class="form-control" id="leftCommissionRate" name="leftCommissionRate" 
                                           value="${matrixConfig?.leftCommissionRate ?: 50}" step="0.1">
                                </div>
                                <div class="col-md-3 mb-3">
                                    <label for="rightCommissionRate" class="form-label">Right Commission</label>
                                    <input type="number" class="form-control" id="rightCommissionRate" name="rightCommissionRate" 
                                           value="${matrixConfig?.rightCommissionRate ?: 50}" step="0.1">
                                </div>
                                <div class="col-md-3 mb-3">
                                    <label for="matchingBonusRate" class="form-label">Matching Bonus</label>
                                    <input type="number" class="form-control" id="matchingBonusRate" name="matchingBonusRate" 
                                           value="${matrixConfig?.matchingBonusRate ?: 0}" step="0.1">
                                </div>
                                <div class="col-md-3 mb-3">
                                    <label for="poolBonusRate" class="form-label">Pool Bonus</label>
                                    <input type="number" class="form-control" id="poolBonusRate" name="poolBonusRate" 
                                           value="${matrixConfig?.poolBonusRate ?: 0}" step="0.1">
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="description" class="form-label">Description</label>
                                <textarea class="form-control" id="description" name="description" rows="2">${matrixConfig?.description ?: ''}</textarea>
                            </div>
                            
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="${createLink(uri: '/matrix/config-dashboard')}" class="btn btn-secondary">
                                    <i class="fas fa-times"></i> Cancel
                                </a>
                                <button type="submit" class="btn btn-warning">
                                    <i class="fas fa-save"></i> Update Configuration
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>