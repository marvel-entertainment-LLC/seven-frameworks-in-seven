(ns zap.core
  (:use compojure.core)
  (:require [compojure.route :as route]
            [compojure.handler :as handler]
            [ring.middleware.resource :refer [wrap-resource]]
            [ring.middleware.params :refer [wrap-params]]
            [ring.middleware.keyword-params :refer [wrap-keyword-params]]
            [clojure.data.json :as json]
            [zap.views :as views]
            [zap.models :as models]))

(comment
  ;
  (GET "/api/projects" []
    (json/write-str (models/all-projects)))
  ;
  ;
  (GET "/api/project/:id" [id]
    (if-let [proj (models/project-by-id id)]
      (json/write-str proj)
      {:status 404 :body ""}))
  (GET "/api/project/:pid/issues" [pid]
    (json/write-str (models/issues-by-project pid)))
  (GET "/api/project/:pid/issue/:iid" [pid iid]
    (json/write-str (models/issue-by-id iid)))
  ;
  )

; New stuff - roshow
; Set limit and offset on params so there are defaults
(defn set-limit-offset [opts]
  (assoc opts :limit (if-let [lim (:limit opts)] (read-string lim) 2) :offset (if-let [off (:offset opts)] (read-string off) 0)))

(defroutes api-routes
  (GET "/projects" [& params]
    (let [opts (set-limit-offset params)] 
      (json/write-str {:data (models/all-projects opts) 
        :limit (:limit opts)
        :offset (:offset opts)})))
  (GET "/project/:id" [id]
    (if-let [proj (models/project-by-id id)]
      (json/write-str proj)
      {:status 404 :body ""}))
  (GET "/project/:pid/issues" [pid]
    (json/write-str (models/issues-by-project pid)))
  (GET "/project/:pid/issue/:iid" [pid iid]
    (json/write-str (models/issue-by-id iid)))

  (POST "/projects" [& params]
    (views/create-project params))
  (DELETE "/project/:id" [id]
    (views/delete-project id))
  (PUT "/project/:id" [id & params]
    (views/edit-project id params))

  ; New stuff - roshow
  (GET "/project/:pid/issue/:iid/comments" [pid iid]
    (json/write-str (models/comments-by-issue iid)))
  (GET "/project/:pid/issue/:iid/comments/:cid" [pid iid cid]
    (json/write-str (models/comment-by-id cid)))
  (POST "/project/:pid/issue/:iid/comments" [pid iid & params]
    (views/create-comment iid params)))

(defroutes app-routes
  (GET "/" []
    (views/index))
  (GET "/projects" []
    (views/projects))
  (GET "/projects/new" []
    (views/new-project))
  (POST "/projects" [& params]
    (views/make-project params))

  (GET "/project/:id/issues" [id]
    (views/issues-by-project id))
  (GET "/project/:id/issue/new" [id]
    (views/new-issue id))
  (POST "/project/:id/issues" [id & params]
    (views/make-issue id params)))

(defroutes all-routes
  (context "" [] app-routes)
  (context "/api" [] api-routes))

(def app
  (-> all-routes
      (wrap-resource "public")
      wrap-keyword-params
      wrap-params))
;
