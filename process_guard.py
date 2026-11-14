# process_guard.py – utility to track and clean up child processes (e.g., Playwright browsers)
# ------------------------------------------------------------------------------
# Usage pattern:
#   from process_guard import ProcessGuard
#   guard = ProcessGuard()
#   pid = guard.start(subprocess.Popen([...]))  # registers the child PID
#   # ... later ...
#   guard.cleanup()  # terminates any still‑alive registered processes
# ------------------------------------------------------------------------------
import subprocess, os, json, atexit, signal, sys
from pathlib import Path

STATE_FILE = Path(__file__).with_name("process_guard_state.json")

class ProcessGuard:
    def __init__(self):
        self._pids = []
        # Load previous state if any (e.g., after crash)
        if STATE_FILE.exists():
            try:
                self._pids = json.load(STATE_FILE)
            except Exception:
                self._pids = []
        atexit.register(self.cleanup)

    def _save_state(self):
        try:
            STATE_FILE.write_text(json.dumps(self._pids))
        except Exception as e:
            print(f"[process_guard] Failed to write state: {e}", file=sys.stderr)

    def start(self, popen_obj: subprocess.Popen) -> int:
        """Register a subprocess.Popen instance and store its PID.
        Returns the PID for convenience.
        """
        pid = popen_obj.pid
        self._pids.append(pid)
        self._save_state()
        return pid

    def cleanup(self):
        """Terminate all registered PIDs that are still alive.
        Called automatically on interpreter exit via atexit.
        """
        for pid in self._pids:
            try:
                # SIGTERM first, then SIGKILL if needed
                os.kill(pid, signal.SIGTERM)
            except ProcessLookupError:
                continue
            except Exception as e:
                print(f"[process_guard] error terminating {pid}: {e}", file=sys.stderr)
        # Give a short grace period, then force kill any remaining
        for pid in self._pids:
            try:
                os.kill(pid, 0)  # check if still exists
                os.kill(pid, signal.SIGKILL)
            except ProcessLookupError:
                continue
            except Exception:
                continue
        # Reset state file
        if STATE_FILE.exists():
            STATE_FILE.unlink()
        self._pids = []
        self._save_state()

# Convenience function for one‑off usage
def guard_subprocess(*args, **kwargs) -> subprocess.Popen:
    """Launch a subprocess and automatically register it for cleanup.
    Example: guard_subprocess(["playwright", "run", "script.js"]).
    """
    guard = ProcessGuard()
    pop = subprocess.Popen(*args, **kwargs)
    guard.start(pop)
    return pop

if __name__ == "__main__":
    # Simple demo when run directly
    print("process_guard ready – PID list persisted at", STATE_FILE)
