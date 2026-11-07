# One JSON per g1 map so a kill loses at most one map. Skips maps already written.
$maps1 = "identity","mono3","shiftsq_c0","shiftsq_c3","root3","cos_w1"
$maps2 = "exp_b1","sinh_b1","mono5","shiftsq_c0.5","shiftsq_c1","shiftsq_c2","cos_w2","cos_w4","root2","root4","root5","spr2s050","spr3s050","spr4s050","spr6s100"
Set-Location "C:\Users\sahas\Github Repos\composite-bo-ablation"
foreach ($m in $maps1 + $maps2) {
  $out = "composite_ablation/results/two_stage_shared/$m.json"
  if (Test-Path $out) { continue }
  Write-Output "=== $m  $(Get-Date -Format s)"
  python composite_ablation/run_two_stage.py --g2 shared --g1 $m --trials 5 --draws 4 --n-init 10 --n-iter 40 --jobs 6 --out $out
}
Write-Output "=== DONE $(Get-Date -Format s)"
