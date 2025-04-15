import argparse

DEFAULT_TMUX = "RUN_CMD"

parser = argparse.ArgumentParser(description="Paralleize commands in separate tmux windows.")
parser.add_argument('-d', '--dir', type=str, required=False, help='directory to change to before executing the script.')
parser.add_argument('-s', '--script', type=str, required=True, help='path to the file containing all commands to be executed, before changing to --dir. This file should have each command to be paralleized on a separate line.')
parser.add_argument('-t', '--tmux_session', type=str, required=False, default=DEFAULT_TMUX, help='name of the tmux session to run commands in, if a session will be reused or created')
args = parser.parse_args()

scripts = ""
with open(args.script, "r") as f:
    scripts = [line.strip() for line in f.readlines()]

print(f"running {len(scripts)} commands in {args.dir}")

cd @(args.dir)

tmux_session_name = args.tmux_session


def create_tmux_session():
    """If the tmux session does not exist, create it."""
    try:
        tmux new-session -d -s @(tmux_session_name)
    except Exception:
        pass


def run_cmd(cmd):
    window_index=$(tmux new-window -t @(TMUX_SESSION_NAME) -P -F "#{window_index}")
    tmux send-keys -t @(TMUX_SESSION_NAME):@(window_index) @(cmd) Enter
    print(f"\t Window: {window_index} --  {cmd}")


create_tmux_session()

for cmd in scripts:
    run_cmd(cmd)
