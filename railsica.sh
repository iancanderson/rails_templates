#!/bin/bash        
if [ -z "$1" ]; then 
  echo usage: $0 APP_NAME
  exit
fi
NAME=$1
TEMPLATE_PATH="~/Code/rails_templates/ica_rails3_template.rb"
rails new $NAME -m $TEMPLATE_PATH -T -J

