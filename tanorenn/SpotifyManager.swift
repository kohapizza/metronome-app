import Foundation

class SpotifyManager: NSObject {
    var tracksData: [Int: [(String, String, String)]] = [:]

    override init() {
        super.init()
        loadTracksData()
    }
    
    func loadTracksData() {
        if let filePath = Bundle.main.path(forResource: "bpm", ofType: "csv") {
            do {
                let content = try String(contentsOfFile: filePath)
                let rows = content.split(separator: "\n").map { String($0) }
                for row in rows.dropFirst() { // Skip the header row
                    let columns = row.split(separator: ",").map { String($0) }
                    if columns.count == 4, let bpm = Int(columns[0]) {
                        let trackName = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        let artistName = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                        let spotifyURL = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                        if tracksData[bpm] != nil {
                            tracksData[bpm]?.append((trackName, artistName, spotifyURL))
                        } else {
                            tracksData[bpm] = [(trackName, artistName, spotifyURL)]
                        }
                    }
                }
            } catch {
                print("Failed to read content of bpm.csv: \(error)")
            }
        }
    }
    
    func getTrackForBpm(bpm: Int) -> (String, String, String)? {
        return tracksData[bpm]?.randomElement()
    }}

