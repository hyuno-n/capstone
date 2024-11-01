from app import create_app, db, socketio
from flask_migrate import Migrate
from flask_script import Manager

app = create_app()
migrate = Migrate(app, db)

if __name__ == '__main__':
    from flask_migrate import upgrade
    app.app_context().push()
    upgrade()
    socketio.run(app, host='0.0.0.0', port=5000,debug=True)
