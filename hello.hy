(import [trytond.pool [PoolMeta Pool]])
(import [trytond.model [fields ModelSingleton ModelSQL ModelView]])

(def --all-- ["Hello" "Configuration"])

(defn no-empty-code-values [values]
  (if (and (in "code" values) (not (get values "code")))
    (do (setv n-values (.copy values))
        (del (get n-values "code"))
        n-values)
    values))


(defclass Configuration [ModelSingleton ModelSQL ModelView]
  "Hello Config"
  [--name-- "hello.configuration"
   sequence (.Many2One fields
                       "ir.sequence"
                       "Sequence"
                       :domain [(, "code" "=" "hello")])])


(defclass Hello []
  "Hello Code"
  [--name-- "hello"
   --metaclass-- PoolMeta
   code (.Char fields "Code")
   ]

  
  (with-decorator classmethod
    (defn write [cls records values &rest args]
      (print "write")
      (.write (super Hello cls) records (no-empty-code-values values) #*
              (->> (partition args 2)
                   (map (fn [pair] [(first pair) (no-empty-code-values (second pair))]))
                   (flatten)
                   (list)))
      ))

  
  (with-decorator classmethod
    (defn create [cls vlist]

      ;; (setv Sequence (.get (Pool) "ir.sequence")
      ;;       sequence (first (.search Sequence (,["code" "=" "hello"]))))

      ;;(setv Sequence (.get (Pool) "ir.sequence")
      ;;      ModelData (.get (Pool) "ir.model.data")
      ;;      sequence-id (.get_id ModelData "hello_code" "sequence_hello"))

      (setv Sequence (.get (Pool) "ir.sequence")
            Configuration (.get (Pool) "hello.configuration")
            config (Configuration 1)
            sequence-id config.sequence.id)
      
      (->>
        vlist
        (map (fn [x]
               (if (not (get x "code"))
                 (do
                   (setv c (.copy x))
                   (assoc c "code" (.get_id Sequence sequence-id))
                   c)
                 x)))
        (list)
        (.create (super Hello cls))
        )
      
      )))

