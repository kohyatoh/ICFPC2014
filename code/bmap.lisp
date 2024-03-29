(letrec (
  (tree (cons (cons 0 1) (cons 2 3)))
  (counter 0)
  (inc (lambda ()
    (set counter (add 2 counter))
    counter))
  (binit (lambda (f h)
    (if h
      (cons (call binit f (div h 2)) (call binit f (div h 2)))
      (call f))))
  (bget (lambda (n i h)
    (if h
      (if (gt h i)
        (call bget (car n) i (div h 2))
        (call bget (cdr n) (sub i h) (div h 2)))
      n)))
  (bset (lambda (n i x h)
    (if h
      (if (gt h i)
        (cons (call bset (car n) i x (div h 2)) (cdr n))
        (cons (car n) (call bset (cdr n) (sub i h) x (div h 2))))
      x))))
  (call bget tree 2 2)
  (set tree (call binit inc 2))
  (set tree (call bset tree 2 -2 2))
  (call bget tree 2 2))
