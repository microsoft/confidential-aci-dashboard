
echo "<html><body>" > index.html

# Loop through all .html files in the current directory
for file in *.html; do
    if [ "$file" != "index.html" ]; then
        # Add an <a> tag for each .html file
        echo "<a href=\"$file\">$file</a><br>" >> index.html
    fi
done

# Close the HTML tags
echo "</body></html>" >> index.html