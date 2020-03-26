(module mrpc-client-unix (make-client
                          make-unix-port-connector)
        (import scheme
                chicken.base
                chicken.port
                chicken.condition)
        (import (prefix msgpack-rpc-client mrpc:)
                socket
                (only srfi-18 
                      make-mutex
                      mutex-lock!
                      mutex-unlock!))

        (define (raise-closed-error location)
          (signal
            (condition `(exn location ,location
                             message "This unix socket is closed.")
                       '(i/o)
                       '(unix-socket-port))))

        (define (make-flag initial)
          (let ((flag initial)
                (lock (make-mutex)))
            (lambda arg
              (if (null? arg)
                  (let ((res #f))
                    (mutex-lock! lock)
                    (set! res flag)
                    (mutex-unlock! lock)
                    res)
                  (begin
                    (mutex-lock! lock)
                    (set! flag (car arg))
                    (mutex-unlock! lock)
                    (if #f #f))))))

        (define (make-unix-port path)
          (let ((sock (socket af/unix sock/stream))
                (opened (make-flag #t)))
            (socket-connect sock (unix-address path))
            (let ((this-read
                    (lambda ()
                      (if (opened)
                          (socket-receive sock 1)
                          (raise-closed-error 'unix-port-read))))
                  (this-ready?
                    (lambda ()
                      (and (opened) (socket-receive-ready? sock))))
                  (this-close
                    (lambda ()
                      (when (opened)
                        (opened #f)
                        (socket-close sock))))
                  (this-write
                    (lambda (str)
                      (if (opened)
                          (socket-send sock str)
                          (raise-closed-error 'unix-port-write)))))
              (values
                (make-input-port this-read this-ready? this-close)
                (make-output-port this-write this-close)))))

        ;; Return a thunk that connect to the unix socket
        ;; found at path and return two values: in and out ports
        (define (make-unix-port-connector path)
          (lambda ()
            (make-unix-port path)))

        ;; Create a msgpack-rpc-client instance with transport over
        ;; a Unix socket found at path
        (define (make-client path)
          (mrpc:make-client 'extend (make-unix-port-connector path)))
        )
