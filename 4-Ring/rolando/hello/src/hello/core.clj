(ns hello.core
  (:use compojure.core)
  (:require [clojure.data.json :as json]
  			[hiccup.core :refer [html]])) ;(1)

(defn hollaback [echo pecho]
  (html [:h1 "hello, " echo pecho]))

(defroutes app ;(2)
 
  (GET "/" [] ;(3)
  	"hello, world")
  (GET "/html" []
  	(html [:h1 {:class :headline :style "color:red;font-family:monospace;"} "hello, world"]))
  (GET "/echo/:echo" [echo & params]
  	(hollaback echo (:echo params)))
  (GET "/json" []
  	(json/write-str {:hello :world})))
