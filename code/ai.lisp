(let (
  (at (lambda (f l i) (if (eq i 0) (car l) (call f f (cdr l) (sub i 1)))))
  (asfind (lambda (f l x)
    (if (atom l) 0
      (if (eq x (car (car l)))
        (cdr (car l))
        (call f f (cdr l) x)))))
  (asupdate (lambda (l x y) (cons (cons x y) l)))
  (dx (list 1 2 1 0))
  (dy (list 0 1 2 1))
  (mod (lambda (x y) (sub x (mul y (div x y))))))
(let (
  (mapat (lambda (map x y) (call at at (call at at map y) x)))
  (visited 0))
(let (
  (dirtest (lambda (map x y dir)
    (let ((nx (sub (add x (call at at dx dir)) 1))
          (ny (sub (add y (call at at dy dir)) 1)))
      (if (eq 0 (call mapat map nx ny)) 0 1)))))
(let (
  (step (lambda (gst world)
     (let ((map (car world))
           (st  (car (cdr world)))
           (t (cdr gst))
           (a (car gst))
           (p 0)
           (x 0)
           (y 0)
           (nx 0)
           (ny 0)
           (nk 0)
           (ansk 1000)
           (ansz 0))
       (set p (car (cdr st)))
       (set x (car p))
       (set y (cdr p))
       (let ((update (lambda (dir)
         (if (call dirtest map x y dir)
           (seq
             (set nx (sub (add x (call at at dx dir)) 1))
             (set ny (sub (add y (call at at dy dir)) 1))
             (set nk (call asfind asfind visited (add nx (mul ny 1000))))
             (if (gt ansk nk)
               (seq (set ansk nk) (set ansz dir))
               (seq)))
           (seq)))))
         (call update (call mod (add a 0) 4))
         (call update (call mod (add a 1) 4))
         (call update (call mod (add a 2) 4))
         (call update (call mod (add a 3) 4))
         (set nx (sub (add x (call at at dx ansz)) 1))
         (set ny (sub (add y (call at at dy ansz)) 1))
         (set visited (call asupdate visited (add nx (mul ny 1000)) 1))
         (cons (cons ansz (add t 1)) ansz))))))
  (cons (cons 0 1) step)
))))
