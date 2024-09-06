#!/bin/bash

echo "<html><body>" > index.html
echo "<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>" >> index.html
echo '<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(600px, 1fr)); grid-gap: 10px">' >> index.html

# Loop through all .html files in the current directory
for file in *.html; do
    if [ "$file" != "index.html" ]; then
        cat $file >> index.html
        echo "" >> index.html
    fi
done

# Close the HTML tags
echo "</div></body></html>" >> index.html