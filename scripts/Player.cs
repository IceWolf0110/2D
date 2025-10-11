using System;
using Godot;

namespace D.scripts;

public partial class Player : CharacterBody2D
{
    [Export] private int _speed = 1000;
    [Export] private int _maxHorizontalSpeed = 300;
    [Export] private int _slowdownSpeed = 1000;
    
    [Export] private int _jumpSpeed = -300;
    [Export] private int _jumpHorizontalSpeed = 1000;
    [Export] private int _maxJumpHorizontalSpeed = 300;
    
    private const int Gravity = 1000;
    private AnimatedSprite2D _player;

    private enum State
    {
        Idle,
        Run,
        Jump,
        Shoot
    }
    
    private State _currentState;
    
    public override void _Ready()
    {
        _player = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
        _currentState = State.Idle;
    }

    public override void _PhysicsProcess(double delta)
    {
        PlayerFalling(delta);
        PlayerIdle();
        PlayerRun(delta);
        MoveAndSlide();
        PlayerAnimations();
    }

    private void PlayerFalling(double delta)
    {
        if (IsOnFloor()) return;
        
        var velocity = Velocity;
        velocity.Y +=  Gravity * (float) delta;
    }
    
    private void PlayerIdle()
    {
        if (!IsOnFloor()) return;
        _currentState = State.Idle;
    }
    
    private void PlayerRun(double delta)
    {
        if (!IsOnFloor()) return;
        
        var direction = GetDirection();
        var velocity = Velocity;

        if (Convert.ToBoolean(direction))
        {
            velocity.X += direction * _speed * (float) delta;
            velocity.X = Mathf.Clamp(velocity.X, -_maxHorizontalSpeed, _maxHorizontalSpeed);
        }
        else
        {
            velocity.X = Mathf.MoveToward(velocity.X, 0, _slowdownSpeed * (float) delta);
        }
        
        Velocity = velocity;

        if (direction == 0f)
            return;
        
        _currentState = State.Run;
        _player.FlipH = !(direction > 0f);
    }
    
    private void PlayerAnimations()
    {
        if (_currentState != State.Idle)
        {
            if (_currentState != State.Run || _player.Animation == "run_shoot")
            {
                if (_currentState != State.Jump)
                {
                    if (_currentState == State.Shoot)
                    {
                        _player.Play("run_shoot");
                    }
                }
                else
                {
                    _player.Play("jump");
                }
            }
            else
            {
                _player.Play("run");
            }
        }
        else
        {
            _player.Play("idle");
        }
    }

    private static float GetDirection()
    {
        return Input.GetAxis("move_left", "move_right");
    }
}