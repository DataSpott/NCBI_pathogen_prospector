sed -e 's/<[^>]*>//g' | grep -i Antibiogram | sed 's/\b\s\b/_/g' \
| sed 's/Testing_standard/Testing_standard\n/' | sed 's/Antibiotic/\nAntibiotic/' \
| sed 's/&gt;/>/g' | sed 's/&lt;/</g' | tail -n +2 | sed "s/^[ \t]*//" \
| sed "s/ \{11\}/&,/g" | tr -d " " | sed "s/^,*\b//g;s/,/\n/10;P;D" \
| head -n -1