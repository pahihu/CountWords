{
   $0 = tolower($0);
   for (i = 1; i <= NF; i++)
      freq[$i]++;
}

END \
{
   for (k in freq)
      print k,freq[k] | "sort -nr -k2"
}
