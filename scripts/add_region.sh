#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <new_region_name>"
  exit 1
fi

OLD_REGION="westeurope"
NEW_REGION=$1

# Copy and rename the region specific workflow files
for FILE in .github/workflows/*$OLD_REGION.yml;
do
  NEW_FILE=$(echo $FILE | sed "s/$OLD_REGION/$NEW_REGION/")
  cp $FILE $NEW_FILE

  # Find and replace the old region name with the new region name in the new file
  sed -i "s/$OLD_REGION/$NEW_REGION/g" $NEW_FILE

  echo "Processed $FILE to $NEW_FILE"
done

echo "All region specific workflows have been copied and renamed. Update README.md with the new badges"