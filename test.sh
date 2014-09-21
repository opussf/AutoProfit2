#!/bin/sh
date
targetDir="/Applications/World of Warcraft/Interface/AddOns/Autoprofit"
files="AutoProfit.lua AutoProfit.toc AutoProfit.xml"

for f in $files 
do
diff "$targetDir/"$f $f
cp -v $f "$targetDir"
done

