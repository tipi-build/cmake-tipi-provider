#include <iostream>
#include <boost/filesystem.hpp>

int main(int argc, char** argv) {
  std::cout << boost::filesystem::current_path() << std::endl;
  return 0;
}