#include "message_source.cpp"
#include <memory>

using namespace AutumnBot::Client::QQ;
using namespace Cyan;

int main(int argc, char ** argv) {
    std::unique_ptr<Message_Source> message_source(
        new Message_Source(3504920742_qq, "127.0.0.1", "127.0.0.1", 9993, 9993, "AutumnBot"));
    message_source->init();

    std::cin.get();
    return 0;
}
