require 'digest/sha1'
require 'yajl'
require 'features/support/couchdb_api'

class CouchDBHelper

  def initialize(host, port, admin, password)
    @couch = CouchDBApi::Server.new(host, port, "", {:user => admin,
                                                     :password => password})
  end

  def signup_user(authdb, username = "", password = "")
    # create salt and hashed password
    salt = "a salt"
    password_sha = Digest::SHA1.new.hexdigest(salt + password)

    user = {:_id => "org.couchdb.user:#{username}", :name => username,
            :roles => [], :type => "user", :salt => salt,
            :password_sha => password_sha,
            "couch.app.profile" => {:nickname => username,
                                    :email => "#{username}@example.com",
                                    :url => "example.com"
                                   }
           }

    @couch.put("/#{authdb}/org.couchdb.user:#{username}",
               Yajl::Encoder.encode(user))
  end

  def change_auth_db(dbname = "_users")
    if @couch.get("/#{dbname}").code == 404
      @couch.put("/#{dbname}", "")
    end
    @couch.put("/_config/couch_httpd_auth/authentication_db", Yajl::Encoder.encode(dbname))
  end

  def delete_db(dbname)
    @couch.delete("/#{dbname}")
  end

end
