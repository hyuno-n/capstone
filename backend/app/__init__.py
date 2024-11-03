from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_socketio import SocketIO
from flasgger import Swagger, LazyString, LazyJSONEncoder
from dotenv import load_dotenv
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timedelta
import os
import atexit
import threading

db = SQLAlchemy()
migrate = Migrate()
socketio = SocketIO(cors_allowed_origins="*", async_mode='eventlet')

def create_app():
    load_dotenv()
    app = Flask(__name__)
    app.config.from_object('config.DevelopmentConfig')

    db.init_app(app)
    migrate.init_app(app, db)
    socketio.init_app(app)

    with app.app_context():
        from .routes import bp as main_bp
        from .models import EventLog
        app.register_blueprint(main_bp)
        

        def delete_old_logs():
            with app.app_context():
                try:
                    # 테스트용: 현재 시간 기준 10초 이전 데이터 삭제
                    cutoff_time = datetime.utcnow() - timedelta(days=7)
                    old_logs = db.session.query(EventLog).filter(EventLog.timestamp < cutoff_time).all()

                    if old_logs:
                        print(f"{len(old_logs)}개의 오래된 로그를 삭제합니다.")
                        for log in old_logs:
                            print(f"삭제할 로그: ID={log.id}, Timestamp={log.timestamp}")
                        
                        # 실제 삭제 수행
                        db.session.query(EventLog).filter(EventLog.timestamp < cutoff_time).delete()
                        db.session.commit()
                        print("오래된 데이터를 성공적으로 삭제했습니다.")
                    else:
                        print("삭제할 오래된 데이터가 없습니다.")
                
                except Exception as e:
                    print(f"오류 발생: {e}")

        def start_scheduler():
            scheduler = BackgroundScheduler()
            scheduler.add_job(delete_old_logs, 'interval', days=1)  # 20초마다 실행 (테스트용)
            scheduler.start()
            print("스케줄러가 시작되었습니다.")  # 스케줄러 시작 확인용 메시지
            atexit.register(lambda: scheduler.shutdown())
            print("애플리케이션이 종료될 때 스케줄러도 종료됩니다.")

        # 스케줄러를 별도의 스레드에서 실행
        threading.Thread(target=start_scheduler, daemon=True).start()

    return app
