#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIREBASE_CONFIG_FILE=""
EXISTING_ENV_VARS=()

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Advanced Project Setup Script${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate input
validate_input() {
    if [[ -z "$1" ]]; then
        print_error "This field cannot be empty. Please try again."
        return 1
    fi
    return 0
}

# Function to get user input with validation
get_input() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    
    while true; do
        if [[ -n "$default" ]]; then
            echo -n "$prompt [$default]: "
        else
            echo -n "$prompt: "
        fi
        
        read -r input
        
        if [[ -z "$input" && -n "$default" ]]; then
            input="$default"
        fi
        
        if validate_input "$input"; then
            eval "$var_name='$input'"
            break
        fi
    done
}

# Function to detect existing environment variables
detect_existing_env() {
    print_status "Detecting existing environment variables..."
    
    # Look for .env files in the project
    local env_files=($(find . -name ".env*" -type f 2>/dev/null))
    
    for env_file in "${env_files[@]}"; do
        if [[ -f "$env_file" ]]; then
            print_status "Found existing environment file: $env_file"
            while IFS='=' read -r key value; do
                if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]] && [[ -n "$value" ]]; then
                    EXISTING_ENV_VARS+=("$key=$value")
                fi
            done < "$env_file"
        fi
    done
    
    if [[ ${#EXISTING_ENV_VARS[@]} -gt 0 ]]; then
        print_status "Found ${#EXISTING_ENV_VARS[@]} existing environment variables"
    fi
}

# Function to detect Firebase configuration
detect_firebase_config() {
    print_status "Detecting Firebase configuration..."
    
    # Look for firebase config files
    local firebase_files=(
        "firebase.json"
        ".firebaserc"
        "firebase.config.js"
        "firebase.config.json"
    )
    
    for file in "${firebase_files[@]}"; do
        if [[ -f "$file" ]]; then
            FIREBASE_CONFIG_FILE="$file"
            print_status "Found Firebase config: $file"
            break
        fi
    done
    
    if [[ -n "$FIREBASE_CONFIG_FILE" ]]; then
        print_status "Firebase configuration detected: $FIREBASE_CONFIG_FILE"
        return 0
    else
        print_warning "No Firebase configuration found"
        return 1
    fi
}

# Function to extract Firebase config values
extract_firebase_config() {
    if [[ -z "$FIREBASE_CONFIG_FILE" ]]; then
        return 1
    fi
    
    print_status "Extracting Firebase configuration values..."
    
    case "$FIREBASE_CONFIG_FILE" in
        "firebase.json")
            # Extract project ID from firebase.json
            if command_exists jq; then
                FIREBASE_PROJECT_ID=$(jq -r '.emulators.projectId // empty' "$FIREBASE_CONFIG_FILE" 2>/dev/null)
                if [[ -z "$FIREBASE_PROJECT_ID" ]]; then
                    FIREBASE_PROJECT_ID=$(jq -r '.projectId // empty' "$FIREBASE_CONFIG_FILE" 2>/dev/null)
                fi
            fi
            ;;
        ".firebaserc")
            # Extract project ID from .firebaserc
            if command_exists jq; then
                FIREBASE_PROJECT_ID=$(jq -r '.projects.default // empty' "$FIREBASE_CONFIG_FILE" 2>/dev/null)
            fi
            ;;
        "firebase.config.js"|"firebase.config.json")
            # Extract from JS/JSON config
            if command_exists jq; then
                FIREBASE_PROJECT_ID=$(jq -r '.projectId // empty' "$FIREBASE_CONFIG_FILE" 2>/dev/null)
            fi
            ;;
    esac
    
    if [[ -n "$FIREBASE_PROJECT_ID" ]]; then
        print_status "Detected Firebase Project ID: $FIREBASE_PROJECT_ID"
        FIREBASE_STORAGE_BUCKET="${FIREBASE_PROJECT_ID}.appspot.com"
    fi
}

# Function to get Firebase configuration choice
get_firebase_config_choice() {
    if [[ -n "$FIREBASE_CONFIG_FILE" ]]; then
        echo ""
        print_status "Firebase configuration detected. Choose configuration method:"
        echo "1) Use detected configuration (recommended)"
        echo "2) Enter configuration manually"
        echo "3) Skip Firebase configuration"
        
        while true; do
            echo -n "Enter your choice (1-3): "
            read -r firebase_choice
            
            case $firebase_choice in
                1)
                    FIREBASE_CONFIG_METHOD="detected"
                    extract_firebase_config
                    break
                    ;;
                2)
                    FIREBASE_CONFIG_METHOD="manual"
                    break
                    ;;
                3)
                    FIREBASE_CONFIG_METHOD="skip"
                    break
                    ;;
                *)
                    print_error "Invalid choice. Please enter 1, 2, or 3."
                    ;;
            esac
        done
    else
        FIREBASE_CONFIG_METHOD="manual"
    fi
}

# Function to get Firebase configuration manually
get_firebase_config_manual() {
    if [[ "$FIREBASE_CONFIG_METHOD" == "skip" ]]; then
        return 0
    fi
    
    print_step "Firebase Configuration"
    
    if [[ "$FIREBASE_CONFIG_METHOD" == "manual" ]]; then
        get_input "Enter Firebase Project ID" FIREBASE_PROJECT_ID
        FIREBASE_STORAGE_BUCKET="${FIREBASE_PROJECT_ID}.appspot.com"
    fi
    
    get_input "Enter Firebase Storage Bucket" FIREBASE_STORAGE_BUCKET "$FIREBASE_STORAGE_BUCKET"
    get_input "Enter Firebase API Key" FIREBASE_API_KEY
    get_input "Enter Firebase Auth Domain" FIREBASE_AUTH_DOMAIN "${FIREBASE_PROJECT_ID}.firebaseapp.com"
    get_input "Enter Firebase Messaging Sender ID" FIREBASE_MESSAGING_SENDER_ID
    get_input "Enter Firebase App ID" FIREBASE_APP_ID
}

# Function to get project setup choice
get_project_setup_choice() {
    echo ""
    print_status "Choose your project setup method:"
    echo "1) Clone from starter pack (creates new repository)"
    echo "2) Fork from starter pack (keeps connection to original)"
    
    while true; do
        echo -n "Enter your choice (1-2): "
        read -r setup_choice
        
        case $setup_choice in
            1)
                PROJECT_SETUP_METHOD="clone"
                break
                ;;
            2)
                PROJECT_SETUP_METHOD="fork"
                break
                ;;
            *)
                print_error "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
}

# Function to get project information
get_project_info() {
    print_step "Project Information"
    
    get_input "Enter your GitHub username" GITHUB_USERNAME
    get_input "Enter your starter pack repository name" STARTER_REPO "simple-nextjs-starter"
    get_input "Enter the name for your new project" NEW_PROJECT_NAME
    get_input "Enter a description for your new project" PROJECT_DESCRIPTION
    get_input "Enter the local directory name for your new project" LOCAL_DIR_NAME "$NEW_PROJECT_NAME"
    
    # Repository visibility
    echo ""
    print_status "Choose repository visibility:"
    echo "1) Private (recommended for personal projects)"
    echo "2) Public"
    echo "3) Internal (GitHub Enterprise only)"
    
    while true; do
        echo -n "Enter your choice (1-3): "
        read -r visibility_choice
        
        case $visibility_choice in
            1)
                VISIBILITY="private"
                break
                ;;
            2)
                VISIBILITY="public"
                break
                ;;
            3)
                VISIBILITY="internal"
                break
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# Function to setup project from clone
setup_project_from_clone() {
    print_step "Setting up project from clone"
    
    # Clone the starter pack
    print_status "Cloning your starter pack..."
    if [[ -d "$LOCAL_DIR_NAME" ]]; then
        print_warning "Directory '$LOCAL_DIR_NAME' already exists."
        echo -n "Remove it and continue? (y/N): "
        read -r remove_existing
        
        if [[ "$remove_existing" =~ ^[Yy]$ ]]; then
            rm -rf "$LOCAL_DIR_NAME"
        else
            print_error "Please choose a different directory name or remove the existing one."
            exit 1
        fi
    fi
    
    git clone "https://github.com/$GITHUB_USERNAME/$STARTER_REPO.git" "$LOCAL_DIR_NAME"
    
    if [[ $? -ne 0 ]]; then
        print_error "Failed to clone the repository. Please check your repository URL and try again."
        exit 1
    fi
    
    cd "$LOCAL_DIR_NAME"
    
    # Remove old git history
    print_status "Removing old git history..."
    rm -rf .git
    
    # Create new repository
    print_status "Creating new repository..."
    
    if command_exists gh; then
        # Use GitHub CLI
        print_status "Creating repository using GitHub CLI..."
        gh repo create "$NEW_PROJECT_NAME" --"$VISIBILITY" --description "$PROJECT_DESCRIPTION" --source . --push
        
        if [[ $? -ne 0 ]]; then
            print_warning "GitHub CLI failed. You'll need to create the repository manually."
            print_status "Please create the repository at: https://github.com/new"
            echo "Repository name: $NEW_PROJECT_NAME"
            echo "Description: $PROJECT_DESCRIPTION"
            echo "Visibility: $VISIBILITY"
            echo ""
            echo "After creating the repository, run these commands:"
            echo "git remote add origin https://github.com/$GITHUB_USERNAME/$NEW_PROJECT_NAME.git"
            echo "git push -u origin main"
        fi
    else
        # Manual instructions
        print_status "Please create the repository manually:"
        echo "1. Go to: https://github.com/new"
        echo "2. Repository name: $NEW_PROJECT_NAME"
        echo "3. Description: $PROJECT_DESCRIPTION"
        echo "4. Visibility: $VISIBILITY"
        echo "5. Do NOT initialize with README, .gitignore, or license"
        echo "6. Click 'Create repository'"
        echo ""
        
        echo -n "Press Enter when you've created the repository..."
        read -r
        
        # Initialize git and set up remote
        print_status "Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit from starter pack"
        
        print_status "Setting up remote origin..."
        git remote add origin "https://github.com/$GITHUB_USERNAME/$NEW_PROJECT_NAME.git"
        
        print_status "Pushing to new repository..."
        git push -u origin main
    fi
}

# Function to setup project from fork
setup_project_from_fork() {
    print_step "Setting up project from fork"
    
    print_status "Forking your starter pack..."
    
    if command_exists gh; then
        # Use GitHub CLI to fork
        gh repo fork "$GITHUB_USERNAME/$STARTER_REPO" --clone=true --remote-name=origin
        
        if [[ $? -ne 0 ]]; then
            print_error "Failed to fork the repository. Please fork manually from GitHub."
            exit 1
        fi
        
        # Rename the cloned directory
        local forked_dir=$(basename "$STARTER_REPO")
        if [[ -d "$forked_dir" ]]; then
            mv "$forked_dir" "$LOCAL_DIR_NAME"
            cd "$LOCAL_DIR_NAME"
        fi
    else
        print_status "Please fork the repository manually:"
        echo "1. Go to: https://github.com/$GITHUB_USERNAME/$STARTER_REPO"
        echo "2. Click 'Fork' button"
        echo "3. Clone your forked repository"
        echo ""
        
        get_input "Enter your forked repository URL" FORKED_REPO_URL
        
        git clone "$FORKED_REPO_URL" "$LOCAL_DIR_NAME"
        cd "$LOCAL_DIR_NAME"
    fi
    
    # Update package.json
    print_status "Updating package.json..."
    if [[ -f "package.json" ]]; then
        if command_exists jq; then
            jq --arg name "$NEW_PROJECT_NAME" '.name = $name' package.json > temp.json && mv temp.json package.json
        else
            print_warning "jq not found. Please manually update the 'name' field in package.json to '$NEW_PROJECT_NAME'"
        fi
    fi
}

# Function to create environment files
create_environment_files() {
    print_step "Creating environment files"
    
    # Create .env.example for web app
    if [[ -d "apps/web" ]]; then
        print_status "Creating web app environment file..."
        cat > apps/web/.env.example << EOF
# Next.js Environment Variables
# Copy this file to .env.local and fill in your values

# App Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3000

# Firebase Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=${FIREBASE_API_KEY:-your_firebase_api_key}
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN:-your_project.firebaseapp.com}
NEXT_PUBLIC_FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-your_project_id}
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET:-your_project.appspot.com}
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID:-your_sender_id}
NEXT_PUBLIC_FIREBASE_APP_ID=${FIREBASE_APP_ID:-your_app_id}

# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:3001

# Authentication
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your_nextauth_secret

# Database
DATABASE_URL=your_database_connection_string

# External Services
# Add any other external service API keys here
EOF
    fi
    
    # Create .env.example for API app
    if [[ -d "apps/api" ]]; then
        print_status "Creating API app environment file..."
        cat > apps/api/.env.example << EOF
# API Environment Variables
# Copy this file to .env and fill in your values

# Firebase Admin Configuration
FIREBASE_SERVICE_ACCOUNT={"type":"service_account","project_id":"${FIREBASE_PROJECT_ID:-your_project_id}","private_key_id":"your_private_key_id","private_key":"your_private_key","client_email":"your_client_email","client_id":"your_client_id","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"your_cert_url"}
FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET:-your_project.appspot.com}

# Server Configuration
PORT=3001
NODE_ENV=development

# Database Configuration
DATABASE_URL=your_database_connection_string

# Authentication
JWT_SECRET=your_jwt_secret

# External Services
# Add any other external service API keys here
EOF
    fi
    
    # Create root .env.example
    print_status "Creating root environment file..."
    cat > .env.example << EOF
# Workspace Environment Variables
# Copy this file to .env and fill in your values

# Firebase Configuration
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-your_project_id}
FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET:-your_project.appspot.com}

# Development Configuration
NODE_ENV=development

# Database Configuration
DATABASE_URL=your_database_connection_string

# External Services
# Add any other external service API keys here
EOF
}

# Function to install dependencies
install_dependencies() {
    print_step "Installing dependencies"
    
    print_status "Installing project dependencies..."
    
    if command_exists pnpm; then
        print_status "Using pnpm to install dependencies..."
        pnpm install
    elif command_exists yarn; then
        print_status "Using yarn to install dependencies..."
        yarn install
    elif command_exists npm; then
        print_status "Using npm to install dependencies..."
        npm install
    else
        print_error "No package manager found. Please install pnpm, yarn, or npm."
        exit 1
    fi
    
    if [[ $? -ne 0 ]]; then
        print_warning "Dependency installation had issues. You may need to install manually."
    fi
}

# Function to cleanup Firebase config
cleanup_firebase_config() {
    if [[ -n "$FIREBASE_CONFIG_FILE" && "$FIREBASE_CONFIG_METHOD" == "detected" ]]; then
        print_status "Cleaning up Firebase configuration file..."
        
        echo -n "Remove Firebase config file '$FIREBASE_CONFIG_FILE'? (y/N): "
        read -r remove_firebase
        
        if [[ "$remove_firebase" =~ ^[Yy]$ ]]; then
            rm -f "$FIREBASE_CONFIG_FILE"
            print_status "Firebase configuration file removed."
        else
            print_status "Firebase configuration file kept."
        fi
    fi
}

# Function to show final instructions
show_final_instructions() {
    echo ""
    print_status "🎉 Project setup completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Navigate to your new project: cd $LOCAL_DIR_NAME"
    echo "2. Copy .env.example files to .env and fill in your values"
    echo "3. Start developing!"
    echo ""
    
    if [[ "$PROJECT_SETUP_METHOD" == "clone" ]]; then
        print_status "Your new project is available at:"
        echo "https://github.com/$GITHUB_USERNAME/$NEW_PROJECT_NAME"
    else
        print_status "Your forked project is available at:"
        echo "https://github.com/$GITHUB_USERNAME/$NEW_PROJECT_NAME"
    fi
    
    echo ""
    print_status "Local project directory: $LOCAL_DIR_NAME"
    
    if [[ -n "$FIREBASE_CONFIG_FILE" ]]; then
        echo ""
        print_warning "Remember to:"
        echo "- Configure Firebase in your new project"
        echo "- Update Firebase project settings if needed"
    fi
}

# Main script
main() {
    print_header
    
    print_status "This script will help you set up a new project from your starter pack."
    print_status "It supports both cloning and forking, with automatic Firebase detection."
    echo ""
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    
    if ! command_exists git; then
        print_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    if ! command_exists gh; then
        print_warning "GitHub CLI (gh) is not installed. Some features will require manual steps."
        echo "Install it with: brew install gh (macOS) or visit: https://cli.github.com/"
    fi
    
    echo ""
    
    # Detect existing configuration
    detect_existing_env
    detect_firebase_config
    
    # Get user choices
    get_project_setup_choice
    get_project_info
    get_firebase_config_choice
    
    # Confirm before proceeding
    echo ""
    print_status "Please review your settings:"
    echo "Setup Method: $PROJECT_SETUP_METHOD"
    echo "GitHub Username: $GITHUB_USERNAME"
    echo "Starter Repository: $STARTER_REPO"
    echo "New Project Name: $NEW_PROJECT_NAME"
    echo "Description: $PROJECT_DESCRIPTION"
    echo "Local Directory: $LOCAL_DIR_NAME"
    echo "Visibility: $VISIBILITY"
    echo "Firebase Config: $FIREBASE_CONFIG_METHOD"
    
    if [[ "$FIREBASE_CONFIG_METHOD" != "skip" ]]; then
        echo "Firebase Project ID: ${FIREBASE_PROJECT_ID:-Not set}"
    fi
    
    echo ""
    
    echo -n "Proceed with these settings? (y/N): "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled."
        exit 0
    fi
    
    echo ""
    
    # Start the setup process
    print_status "Starting project setup process..."
    
    # Setup project based on choice
    if [[ "$PROJECT_SETUP_METHOD" == "clone" ]]; then
        setup_project_from_clone
    else
        setup_project_from_fork
    fi
    
    # Get Firebase configuration if needed
    if [[ "$FIREBASE_CONFIG_METHOD" != "skip" ]]; then
        get_firebase_config_manual
    fi
    
    # Create environment files
    create_environment_files
    
    # Install dependencies
    install_dependencies
    
    # Cleanup Firebase config if requested
    cleanup_firebase_config
    
    # Show final instructions
    show_final_instructions
}

# Run the main function
main "$@"
