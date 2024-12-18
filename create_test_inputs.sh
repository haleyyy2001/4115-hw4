#!/usr/bin/env bash

# t1.txt - Peephole Optimization (merging identical notes)
# Two identical notes -> one merged note
cat > t1.txt <<EOF
title="Peephole Test";
instrument=Piano;
bpm=120;

play (
  Do4# quarter,
  Do4# quarter
);

end
EOF

# t2.txt - Dead Store Elimination (headers)
# Multiple assignments leave only the last effective
cat > t2.txt <<EOF
title="Dead Store Test";
instrument=Piano;
instrument=Guitar;
bpm=120;
bpm=90;

play (
  Re4- quarter
);

end
EOF

# t3.txt - Loop Unrolling
# We simulate loop unrolling: pitch=-1 and length=2 means repeat the next 2 notes twice.
# After this marker, we place 2 notes that should be duplicated.
#!/usr/bin/env bash

cat > t3.txt <<EOF
title="Loop Unrolling Test";
instrument=Piano;
bpm=120;

play (
  repeat(Do4# quarter, So4- eighth),
  Re4- quarter
);

end



EOF


# t4.txt - Another Peephole Optimization
# 4 identical notes: should fully merge into one after two passes.
cat > t4.txt <<EOF
title="Additional Peephole Test";
instrument=Piano;
bpm=120;

play (
  Do4# quarter,
  Do4# quarter,
  Do4# quarter,
  Do4# quarter
);

end
EOF

echo "Test input files t1.txt, t2.txt, t3.txt, and t4.txt have been created."
