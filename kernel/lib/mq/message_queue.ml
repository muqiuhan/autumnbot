include Saturn.Relaxed_queue
include Saturn.Relaxed_queue.Not_lockfree

type message_queue = Message.Type.t Saturn.Relaxed_queue.t