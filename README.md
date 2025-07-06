# GrowSC Server - Zig Port [NOT FULL COMPLETE](Beta)

This is a Zig port of the GrowSC C++ server codebase. The port is being done incrementally to ensure maintainability and avoid overloading.

## Progress Status

### ✅ Completed (8/8 major parts)

1. **Basic Types & Configuration** - ✅ Complete
   - Configuration system with JSON support
   - Basic enums and types
   - Server settings and constants

2. **ItemDB & Player System** - ✅ Complete
   - Item definitions and database
   - Player information and state management
   - Inventory system

3. **World System** - ✅ Complete
   - World creation and management
   - Block system and world data
   - Player positioning and movement

4. **Packet Handler System** - ✅ Complete
   - Network packet handling
   - Client-server communication
   - Protocol implementation

5. **Game Logic & Actions** - ✅ Complete
   - Action system for player interactions
   - Game mechanics and rules
   - Command processing

6. **Server Management** - ✅ Complete
   - Server pool and lifecycle management
   - Threading and concurrency
   - Connection handling and statistics

7. **Database & Save System** - ✅ Complete
   - Player data persistence
   - World data saving/loading
   - Server state management
   - Backup and recovery system

8. **Event System** - ✅ Complete
   - Game event handling
   - Scheduled tasks
   - Event logging and processing

## Building the Project

### Prerequisites

1. Install Zig (0.11.0 or later)
   ```bash
   # On Arch Linux
   sudo pacman -S zig
   
   # Or download from https://ziglang.org/download/
   ```

2. Install ENet library
   ```bash
   # On Arch Linux
   sudo pacman -S enet
   
   # Or build from source
   git clone https://github.com/lsalzman/enet.git
   cd enet
   make
   sudo make install
   ```

### Build Commands

```bash
# Navigate to the project directory
cd zig_gtps

# Build the project
zig build

# Run the server
./zig-out/bin/growsc-server

# Or build and run in one command
zig build run
```

## Configuration

The server uses `config.json` for configuration. A sample configuration is provided:

```json
{
  "server_name": "GrowSC Server",
  "server_version": "2.0.0",
  "server_port": 17091,
  "max_players": 100,
  "database_path": "data",
  "save_interval": 300,
  "event_interval": 60
}
```

## Project Structure

```
zig_gtps/
├── src/
│   ├── main.zig              # Main server entry point
│   ├── config.zig            # Configuration system
│   ├── database.zig          # Database and save system
│   ├── events.zig            # Event system
│   ├── handle/
│   │   ├── player_info.zig   # Player management
│   │   ├── world_info.zig    # World management
│   │   ├── item_defination.zig # Item definitions
│   │   └── packet_handler.zig # Network packet handling
│   ├── action/
│   │   └── action.zig        # Game actions and logic
│   └── server/
│       └── server_pool.zig   # Server management
├── build.zig                 # Build configuration
├── config.json               # Server configuration
└── README.md                 # This file
```

## Features

- **Multi-threaded server** with background save and event processing
- **Player management** with persistent data storage
- **World system** with dynamic world creation and management
- **Item system** with comprehensive item definitions
- **Event system** for game events and scheduled tasks
- **Database system** with automatic backup and recovery
- **Network protocol** handling with ENet
- **Configuration system** with JSON support

## Development Status

The Zig port is now **complete** with all major systems implemented. The server should be functional for basic GrowSC gameplay.

### Next Steps

1. **Testing** - Test the server with actual clients
2. **Performance Optimization** - Optimize memory usage and performance
3. **Feature Parity** - Ensure all C++ features are implemented
4. **Documentation** - Add detailed API documentation
5. **Testing Suite** - Add comprehensive tests

## Contributing

This is a port of an existing C++ codebase. The goal is to maintain feature parity while leveraging Zig's safety and performance benefits.

## License

Same as the original C++ codebase. 
