#!/bin/bash

set -e

echo "This script will destroy all Azure resources managed by Terraform in this project"
echo ""

terraform destroy

echo ""
echo "Cleanup complete"
