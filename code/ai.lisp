(let (
  (at (lambda (f l i) (if (eq i 0) (car l) (call f f (cdr l) (sub i 1)))))
  (dx (list 1 2 1 0))
  (dy (list 0 1 2 1))
  (mod (lambda (x y) (sub x (mul y (div x y))))))
(let (
  (mapat (lambda (map x y) (call at at (call at at map y) x))))
(let (
  (dirtest (lambda (map x y dir)
    (let ((nx (sub (add x (call at at dx dir)) 1))
          (ny (sub (add y (call at at dy dir)) 1)))
      (if (eq 0 (call mapat map nx ny)) 0 1)))))
(let (
  (step (lambda (a world)
     (let ((map (car world))
           (st  (car (cdr world)))
           (p 0)
           (x 0)
           (y 0)
           (z 0))
       (set p (car (cdr st)))
       (set x (car p))
       (set y (cdr p))
       (set z
         (if (call dirtest map x y a) a
         (if (call dirtest map x y (call mod (add a 1) 4)) (call mod (add a 1) 4)
         (if (call dirtest map x y (call mod (add a 2) 4)) (call mod (add a 2) 4)
         (call mod (add a 3) 4)))))
       (cons z z)))))
  (cons 1 step)
))))
