-include .env
remove :; find . -name .git -type d -not -path "./.git" -exec rm -rf {} +