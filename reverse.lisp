(λ 0 ((λ 0 0) (λλλλ 1 (3 3) (λ 0 3 1))) (λλ 0))
;;;;

(λ 
 (apply 0 
	(apply 
	 (λ (apply 0 
		   0))
	 (λλλλ 
	  (apply 
	   (apply 1 
		  (apply 3 
			 3)) 
	   (λ 
	    (apply 0 
		   (apply 3 
			  1)))))))
 (λλ 0))
;;;;

(defun reverse (lis)
  (cons (reverse (cdr lis)
		 (car lis))))

