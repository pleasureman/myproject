#!/bin/bash

rm -f info.csv || echo "no info.csv"
subject=""
subject_start="yes"
author_start="no"

#sed -e "s#’#'#g" -e 's#—#-#g' -e 's#®##g' conf > conf1 
#sed -e "s#’#'#g" -e "s#–#-#g" -e 's#®##g' conf > conf1
sed -e "s#’#'#g" -e "s#–#-#g" -e 's#®##g' -e "s#—#-#g" -e "s#‘#'#g" -e "s#’#'#g" -e "s#…#...#g" conf > conf1

while read opt; 
do \
{
	if [ "$opt" == "" ];then
		subject_start="yes"
		continue;
	fi

	if [ ${subject_start} == "yes" ];then
		subject=`echo $opt | sed 's/,/\,/g'`
		subject_start="no"
		author_start="yes"
	elif [ ${author_start} == "yes" ];then
		author=$opt
		author_name=`echo $author | awk -F "," '{print $1}' | sed 's/^ //'`
		#author_company=`echo $author | awk -F "," '{print $2$3$4$5}' | sed 's/^ //'`
		#author_company=`echo $author | sed '/s/^${author_name},//'`
		author_company=`echo $author | sed -e 's/^[^,]*,//' -e 's/^ //'`

		echo "author=$author;author_name=$author_name;author_company=$author_company"
		echo "${author_name},\"${author_company}\",,\"${subject}\"" >> info.csv

	fi
}
done < conf1

