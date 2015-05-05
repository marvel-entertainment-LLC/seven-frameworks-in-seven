;
(ns zap.models
  (:refer-clojure :exclude [comment])
  (:use korma.db korma.core)
  (:require [clojure.data.json :as json]
            [clojure.string :as string]))

(defdb zap ;;(2)
  (sqlite3 {:db "zap.db"}))

(defentity project
  (entity-fields :id :name)) ;;(3)

(declare comment)
(defentity issue
  (entity-fields :id :project_id :title :description :status)
  (has-many comment)) ;;(4)

(defentity status
  (entity-fields :id :name))

(defentity tag
  (entity-fields :id :issue_id :tag))

(defentity comment
  (entity-fields :id :issue_id :content)
  (belongs-to issue)) ;;(5)
;

; New stuff - roshow
; using multiple argument option and passing options for API calls 
(defn all-projects 
  ([] (select project))
  ([opts]
    (select project
      (offset (:offset opts))
      (limit (:limit opts)))))

(defn create-project [proj]
  (insert project (values proj)))

(defn project-by-id [id]
  (first (select project (where {:id id})))) ;;(6)
;

(defn all-issues []
  (select issue))

;
(defn- issue-query [] ;;(7)
  (-> (select* issue) ;;(8)
      (fields [:issue.id :id] ;;(9)
              :project_id
              :title
              :description
              [:status.id :status_id]
              [:status.name :status_name])
      (join status (= :issue.status :status.id)))) ;;(10)

(defn issues-by-project [id]
  (-> (issue-query)
      (where {:issue.project_id id})
      exec)) ;;(12)

(defn issue-by-id [id]
  (-> (issue-query)
      (where {:issue.id id})
      exec
      first))
;

(defn comments-by-issue [id]
  (select comment
          (where {:issue_id id})
          (order :id)))

(defn comment-by-id [id]
  (first (select comment
          (where {:id id}))))

(defn status-by-name [s]
  (first (select status (where {:name s}))))

(defn delete-project [id]
  (delete project (where {:id id})))

(defn update-project [id params]
  (update project
          (set-fields params)
          (where {:id id})))

(defn create-issue [params]
  (insert issue (values (select-keys params [:project_id :description :status]))))

(defn create-comment [params]
  (insert comment (values (select-keys params [:issue_id :content]))))

(defn close-issue [id sid]
  (update issue
          (set-fields {:status sid})
          (where {:id id})))

;
(defn find-issues [q]
  (let [q (str "%" (string/lower-case q) "%")]
    (-> (issue-query)
        (where (or (like (sqlfn lower :issue.title) q)
                   (like (sqlfn lower :issue.description) q)))
        exec)))
;
