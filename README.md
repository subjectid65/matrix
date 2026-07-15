# MLM Matrix Plan System

A Multi-Level Marketing (MLM) management system with Matrix Plan placement features built with Grails/Groovy.

## Features

### Core MLM Features
- **Matrix Plan Placement Algorithm**: Automatic placement of downlines in a matrix grid
- **Binary Leg Tracking**: Track left and right leg counts for commission calculations
- **Genealogy Tree**: View complete sponsorship tree structure
- **Member Management**: Full CRUD operations for member management
- **Matrix Configuration**: Customizable matrix dimensions and commission rates

### Matrix Plan Logic
- Members are placed in a configurable grid (width x height)
- Each member has a left leg and right leg
- New members are placed in the first available position
- Placement prioritizes left leg, then right leg
- When both legs are balanced, prefer the leg with fewer members
- When a leg is full, placement moves to the next available position

## Project Structure

```
grails-app/
├── conf/
│   └── application.yml          # Application configuration
├── controllers/
│   ├── mlm/
│   │   ├── MemberController.groovy    # Member management
│   │   ├── MatrixController.groovy    # Matrix operations
│   │   └── UrlMappings.groovy         # URL routing
├── domain/
│   └── mlm/
│       ├── Member.groovy                # Member entity
│       ├── PlacementTransaction.groovy  # Placement history
│       └── MatrixConfig.groovy          # Matrix configuration
├── services/
│   └── mlm/
│       ├── MatrixService.groovy         # Core placement algorithm
│       ├── MemberService.groovy         # Member operations
│       ├── MatrixConfigService.groovy   # Config management
│       └── InitDataService.groovy       # Data initialization
├── views/
│   ├── member/
│   │   ├── index.gsp                   # Member list
│   │   ├── show.gsp                    # Member details
│   │   ├── create.gsp                  # Add member form
│   │   └── edit.gsp                    # Edit member form
│   ├── matrix/
│   │   ├── visualization.gsp           # Matrix grid view
│   │   ├── quickPlacement.gsp          # Quick placement form
│   │   ├── configDashboard.gsp         # Config management
│   │   ├── createConfig.gsp            # Create config form
│   │   └── editConfig.gsp              # Edit config form
│   ├── layouts/
│   │   └── main.gsp                    # Main layout
│   ├── index.gsp                       # Dashboard
│   ├── error.gsp                       # Error page
│   └── notFound.gsp                    # 404 page
```

## Getting Started

### Prerequisites
- Java 17 or higher
- Gradle (included via gradlew)
- Grails 5.x

### Running the Application

```bash
# Build the project
./gradlew build

# Run the development server
./gradlew run

# Or using Windows
gradlew.bat run
```

The application will start on `http://localhost:8080`

## Matrix Configuration

### Default Settings
- **Matrix Width**: 3 columns
- **Matrix Height**: 3 rows
- **Slots per Leg**: 4 (for 3x3 matrix)
- **Left Commission**: 50%
- **Right Commission**: 50%

### Available Templates
| Template | Size | Slots per Leg |
|----------|------|---------------|
| Small | 2x3 | 2 |
| Medium | 3x3 | 4 |
| Large | 4x3 | 6 |
| XL | 5x4 | 16 |

## API Endpoints

### Member API
```
GET    /api/v1/members              - List all members
GET    /api/v1/members/{id}         - Get member by ID
POST   /api/v1/members/search       - Search members
```

### Matrix API
```
GET    /api/v1/matrix/stats         - Get organization statistics
GET    /api/v1/matrix/member/{id}   - Get member matrix data
```

## Database Schema

### Members Table (mlm_member)
| Column | Type | Description |
|--------|------|-------------|
| id | BIGINT | Primary key |
| user_id | VARCHAR | Unique user identifier |
| user_name | VARCHAR | Username |
| full_name | VARCHAR | Full display name |
| email | VARCHAR | Email address |
| phone_number | VARCHAR | Phone number |
| password | VARCHAR | Encrypted password |
| sponsor_id | VARCHAR | Upline sponsor ID |
| parent_id | BIGINT | Direct parent in matrix |
| matrix_width | INT | Matrix width |
| matrix_height | INT | Matrix height |
| position | INT | Matrix position |
| left_leg_count | INT | Left leg member count |
| right_leg_count | INT | Right leg member count |
| placement_position | VARCHAR | Placement position string |
| status | VARCHAR | Member status |
| level | INT | Organization level |
| join_date | DATE | Registration date |
| created_at | TIMESTAMP | Record created timestamp |
| updated_at | TIMESTAMP | Record updated timestamp |

### Matrix Config Table (mlm_matrix_config)
| Column | Type | Description |
|--------|------|-------------|
| id | BIGINT | Primary key |
| config_name | VARCHAR | Configuration name |
| matrix_width | INT | Number of columns |
| matrix_height | INT | Number of rows |
| max_levels | INT | Maximum depth |
| left_commission_rate | DOUBLE | Left commission % |
| right_commission_rate | DOUBLE | Right commission % |
| matching_bonus_rate | DOUBLE | Matching bonus % |
| pool_bonus_rate | DOUBLE | Pool bonus % |
| status | VARCHAR | Active/Inactive |

## License

This project is for educational and commercial use.

## Support

For issues and questions, please contact the development team.