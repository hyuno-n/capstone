"""Initial migration after reset

Revision ID: 5b611fc66281
Revises: 
Create Date: 2024-11-02 01:49:38.398989

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '5b611fc66281'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('users',
    sa.Column('id', sa.String(length=50), nullable=False),
    sa.Column('email', sa.String(length=120), nullable=False),
    sa.Column('phone', sa.String(length=20), nullable=False),
    sa.Column('address', sa.String(length=255), nullable=False),
    sa.Column('detailed_address', sa.String(length=255), nullable=False),
    sa.Column('password_hash', sa.String(length=128), nullable=False),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('email')
    )
    op.create_table('cameras',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('user_id', sa.String(length=50), nullable=False),
    sa.Column('camera_number', sa.Integer(), nullable=False),
    sa.Column('rtsp_url', sa.String(length=255), nullable=False),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('detection_status',
    sa.Column('user_id', sa.String(length=50), nullable=False),
    sa.Column('camera_number', sa.Integer(), nullable=False),
    sa.Column('fall_detection_on', sa.Boolean(), nullable=True),
    sa.Column('fire_detection_on', sa.Boolean(), nullable=True),
    sa.Column('movement_detection_on', sa.Boolean(), nullable=True),
    sa.Column('roi_detection_on', sa.Boolean(), nullable=True),
    sa.Column('roi_x1', sa.Integer(), nullable=True),
    sa.Column('roi_y1', sa.Integer(), nullable=True),
    sa.Column('roi_x2', sa.Integer(), nullable=True),
    sa.Column('roi_y2', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('user_id', 'camera_number')
    )
    op.create_table('event_logs',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('user_id', sa.String(length=50), nullable=False),
    sa.Column('timestamp', sa.DateTime(), nullable=True),
    sa.Column('eventname', sa.String(length=50), nullable=False),
    sa.Column('camera_number', sa.Integer(), nullable=False),
    sa.Column('event_url', sa.String(length=255), nullable=True),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('event_logs')
    op.drop_table('detection_status')
    op.drop_table('cameras')
    op.drop_table('users')
    # ### end Alembic commands ###