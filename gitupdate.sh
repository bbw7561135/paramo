#!/bin/bash
echo -e "Commit?"
read com
git add -A
git status
git commit -m "$com"
git push origin zkd:wmkwwk11@paramozkd
