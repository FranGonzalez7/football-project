import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/players/widgets/player_sort_menu.dart';

List<Player> sortPlayers(List<Player> players, PlayerSortOption option) {
  players.sort((a, b) {
    switch (option) {
      case PlayerSortOption.nameAsc:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case PlayerSortOption.nameDesc:
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      case PlayerSortOption.scoreAsc:
        return a.points.compareTo(b.points);
      case PlayerSortOption.scoreDesc:
        return b.points.compareTo(a.points);
    }
  });
  return players;
}
