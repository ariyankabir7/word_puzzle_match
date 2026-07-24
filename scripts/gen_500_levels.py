import json
import random
import os

random.seed(2026)

WORD_BANK = [
    # Animals
    "CAT", "DOG", "OWL", "FOX", "COW", "PIG", "HEN", "ANT", "BEE", "EEL",
    "APE", "BAT", "ELK", "EMU", "GNU", "JAY", "KOI", "RAM", "RAT", "YAK",
    "BEAR", "BIRD", "BUCK", "BULL", "CALF", "CRAB", "CROW", "DEER", "DOVE",
    "DUCK", "FAWN", "FISH", "FROG", "GOAT", "HARE", "HAWK", "IBIS", "KITE",
    "LAMB", "LION", "LYNX", "MOLE", "MOTH", "MULE", "NEWT", "PONY", "PUMA",
    "SLUG", "SWAN", "TOAD", "WASP", "WORM", "WREN", "CAMEL", "TIGER", "ZEBRA",
    "PANDA", "KOALA", "OTTER", "EAGLE", "ROBIN", "SHARK", "WHALE", "SQUID",
    # Nature
    "SUN", "SKY", "SEA", "ICE", "DEW", "FOG", "MUD", "OAK", "ELM", "IVY",
    "BARK", "CLAY", "CLOD", "DAWN", "DUSK", "FERN", "FIRE", "GALE", "GUST",
    "HAIL", "HILL", "LAKE", "LEAF", "MIST", "MOON", "PEAT", "PINE", "POOL",
    "RAIN", "REEF", "ROCK", "SAND", "SEED", "SNOW", "SOIL", "STAR", "STEM",
    "STORM", "TIDE", "TREE", "VALE", "VINE", "WAVE", "WIND", "WOOD", "FLOWER",
    "OCEAN", "RIVER", "BEACH", "CLOUDS", "DESERT", "FOREST", "GALAXIES",
    # Objects / Food / Misc
    "BAG", "BED", "BOX", "CUP", "HAT", "JUG", "KEY", "MAP", "MUG", "NET",
    "PAN", "PEN", "POT", "ROD", "RUG", "SAW", "TAP", "TIN", "TUB", "VAN",
    "BALL", "BELL", "BELT", "BOAT", "BOOK", "BOOT", "BOWL", "CAGE", "CAKE",
    "CALL", "CARD", "CART", "CASE", "COAT", "COIN", "COMB", "CORD", "CORK",
    "CORN", "CROP", "DISH", "DOME", "DOOR", "DRUM", "FORK", "GATE",
    "GEAR", "GIFT", "GLUE", "GOLD", "GOWN", "GRID", "HALL", "HAND", "HARP",
    "HOOD", "HOOK", "HORN", "HOSE", "IRON", "JADE", "KITE", "LAMP",
    "LOCK", "MAZE", "MILL", "MINE", "MINT", "NAIL", "NEST", "NOTE",
    "OPAL", "PAGE", "PARK", "PIPE", "PLAN", "PLUM", "POST", "PUMP", "RING",
    "ROPE", "ROSE", "RUBY", "RULE", "SAIL", "SALT", "SHIP", "SHOE", "SHOP",
    "SILK", "SOCK", "SOFA", "SONG", "STEP", "WICK", "WIRE", "WOOL", "WORD",
    "APPLE", "BANANA", "CANDY", "PEACH", "HONEY", "PIZZA", "BREAD", "CHEESE",
    "CHERRY", "MANGO", "LEMON", "SUGAR", "SWEET", "MILK", "JUICE", "WATER",
    # Colors & Fun
    "RED", "BLUE", "GREEN", "GOLD", "PINK", "GRAY", "TEAL", "PURPLE", "YELLOW",
    "SILVER", "BRONZE", "SHINE", "SMILE", "HAPPY", "MAGIC", "DREAM", "LIGHT"
]

WORLD_NAMES = [
    "Green Valley",
    "Sunny Beach",
    "Mystic Forest",
    "Snowy Peaks",
    "Desert Dunes",
    "Sky Kingdom",
    "Ocean Deep",
    "Candy Land",
    "Volcano Isle",
    "Star Galaxy",
]

DIRECTION_DELTAS = {
    'LR': (0, 1),
    'RL': (0, -1),
    'TB': (1, 0),
    'BT': (-1, 0),
    'DIAG_DOWN': (1, 1),
    'DIAG_UP': (-1, 1),
    'DIAG_DOWN_REV': (1, -1),
    'DIAG_UP_REV': (-1, -1)
}

WORLD_SETTINGS = {
    1: {'gridSize': 6, 'difficulty': 1, 'directions': ['LR', 'TB'], 'timeLimit': 180},
    2: {'gridSize': 7, 'difficulty': 2, 'directions': ['LR', 'TB', 'DIAG_DOWN', 'DIAG_UP'], 'timeLimit': 150},
    3: {'gridSize': 7, 'difficulty': 2, 'directions': ['LR', 'TB', 'DIAG_DOWN', 'DIAG_UP'], 'timeLimit': 150},
    4: {'gridSize': 7, 'difficulty': 2, 'directions': ['LR', 'TB', 'DIAG_DOWN', 'DIAG_UP'], 'timeLimit': 150},
    5: {'gridSize': 8, 'difficulty': 3, 'directions': ['LR', 'TB', 'RL', 'BT', 'DIAG_DOWN', 'DIAG_UP'], 'timeLimit': 120},
    6: {'gridSize': 8, 'difficulty': 3, 'directions': ['LR', 'TB', 'RL', 'BT', 'DIAG_DOWN', 'DIAG_UP'], 'timeLimit': 120},
    7: {'gridSize': 8, 'difficulty': 3, 'directions': ['LR', 'TB', 'RL', 'BT', 'DIAG_DOWN', 'DIAG_UP'], 'timeLimit': 120},
    8: {'gridSize': 9, 'difficulty': 4, 'directions': ['LR', 'TB', 'RL', 'BT', 'DIAG_DOWN', 'DIAG_UP', 'DIAG_DOWN_REV', 'DIAG_UP_REV'], 'timeLimit': 105},
    9: {'gridSize': 9, 'difficulty': 4, 'directions': ['LR', 'TB', 'RL', 'BT', 'DIAG_DOWN', 'DIAG_UP', 'DIAG_DOWN_REV', 'DIAG_UP_REV'], 'timeLimit': 105},
    10: {'gridSize': 9, 'difficulty': 4, 'directions': ['LR', 'TB', 'RL', 'BT', 'DIAG_DOWN', 'DIAG_UP', 'DIAG_DOWN_REV', 'DIAG_UP_REV'], 'timeLimit': 105},
}

def can_place(grid, word, r, c, dr, dc, grid_size):
    for i, ch in enumerate(word):
        nr, nc = r + dr * i, c + dc * i
        if not (0 <= nr < grid_size and 0 <= nc < grid_size):
            return False
        if grid[nr][nc] not in ('.', ch):
            return False
    return True

def place_word(grid, word, r, c, dr, dc):
    for i, ch in enumerate(word):
        grid[r + dr * i][c + dc * i] = ch

def make_level(level_id, world_num):
    settings = WORLD_SETTINGS[world_num]
    grid_size = settings['gridSize']
    allowed_dirs = settings['directions']
    
    word_count = random.randint(4, 6) if grid_size <= 7 else random.randint(5, 7)
    max_len = grid_size
    
    candidate_words = [w for w in WORD_BANK if 3 <= len(w) <= max_len]
    random.shuffle(candidate_words)
    
    grid = [['.' for _ in range(grid_size)] for _ in range(grid_size)]
    positions = []
    placed_words = []
    
    for word in candidate_words:
        if len(placed_words) >= word_count:
            break
            
        placed = False
        dirs = list(allowed_dirs)
        random.shuffle(dirs)
        
        for d in dirs:
            dr, dc = DIRECTION_DELTAS[d]
            start_coords = [(r, c) for r in range(grid_size) for c in range(grid_size)]
            random.shuffle(start_coords)
            
            for r, c in start_coords:
                if can_place(grid, word, r, c, dr, dc, grid_size):
                    place_word(grid, word, r, c, dr, dc)
                    positions.append({
                        'word': word,
                        'startRow': r,
                        'startCol': c,
                        'direction': d
                    })
                    placed_words.append(word)
                    placed = True
                    break
            if placed:
                break

    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    for r in range(grid_size):
        for c in range(grid_size):
            if grid[r][c] == '.':
                grid[r][c] = random.choice(letters)

    return {
        'id': level_id,
        'world': WORLD_NAMES[world_num - 1],
        'difficulty': settings['difficulty'],
        'gridSize': grid_size,
        'words': placed_words,
        'grid': grid,
        'wordPositions': positions,
        'timeLimit': settings['timeLimit']
    }

def main():
    os.makedirs('/home/kabir/Projects/VishalProjects/word_puzzle_match/assets/levels', exist_ok=True)
    
    for world_num in range(1, 11):
        start_id = (world_num - 1) * 50 + 1
        levels = []
        for i in range(50):
            lvl_id = start_id + i
            levels.append(make_level(lvl_id, world_num))
            
        world_data = {
            'world': WORLD_NAMES[world_num - 1],
            'worldNumber': world_num,
            'levels': levels
        }
        
        filepath = f'/home/kabir/Projects/VishalProjects/word_puzzle_match/assets/levels/world{world_num}.json'
        with open(filepath, 'w') as f:
            json.dump(world_data, f, indent=2)
        print(f"Generated {filepath} with {len(levels)} levels (ID {start_id} to {start_id + 49})")

if __name__ == '__main__':
    main()
