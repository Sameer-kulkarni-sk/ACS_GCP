#!/bin/bash

# Google App Engine Deployment Script
# This script automates the deployment process to GAE

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Google App Engine Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"

# Get project ID
PROJECT_ID=$(gcloud config get-value project)
echo -e "\n${YELLOW}Deploying to project: ${PROJECT_ID}${NC}"

# Install dependencies
echo -e "\n${YELLOW}Installing dependencies...${NC}"
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Check if App Engine app exists
if ! gcloud app describe &> /dev/null; then
    echo -e "\n${YELLOW}Creating App Engine app...${NC}"
    echo "Select a region:"
    echo "1) us-central"
    echo "2) europe-west"
    echo "3) asia-northeast"
    read -p "Enter your choice (1-3): " region_choice
    
    case $region_choice in
        1) REGION="us-central" ;;
        2) REGION="europe-west" ;;
        3) REGION="asia-northeast" ;;
        *) REGION="us-central" ;;
    esac
    
    gcloud app create --region=$REGION
    echo -e "${GREEN}✓ App Engine app created${NC}"
fi

# Deploy
echo -e "\n${YELLOW}Deploying application...${NC}"
gcloud app deploy --quiet
echo -e "${GREEN}✓ Application deployed${NC}"

# Get app URL
APP_URL=$(gcloud app describe --format='value(defaultHostname)')
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Application URL: ${GREEN}https://${APP_URL}${NC}"
echo -e "\n${YELLOW}Useful commands:${NC}"
echo "  View logs:        gcloud app logs read -n 50"
echo "  Open in browser:  gcloud app browse"
echo "  View versions:    gcloud app versions list"
echo "  Stop version:     gcloud app versions stop VERSION_ID"

# Ask if user wants to open in browser
read -p "Open application in browser? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gcloud app browse
fi
