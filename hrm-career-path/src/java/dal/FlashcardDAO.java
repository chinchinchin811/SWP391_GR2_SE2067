package dal;

import model.Flashcard.Flashcard;
import model.Flashcard.FlashcardDeck;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class FlashcardDAO {

    public List<FlashcardDeck> getAllDecks() {
        List<FlashcardDeck> list = new ArrayList<>();
        String sql = "SELECT d.deck_id, d.title, d.description, d.deck_type, d.position_id, p.position_name "
                + "FROM dbo.FlashcardDecks d LEFT JOIN dbo.Positions p ON p.position_id = d.position_id "
                + "ORDER BY CASE WHEN d.deck_type = 'culture' THEN 0 ELSE 1 END, p.position_name, d.title, d.deck_id";
        try (Connection conn = DBContext.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapDeck(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the tai danh sach bo Flashcard", e);
        }
        return list;
    }

    public FlashcardDeck getDeckById(int deckId) {
        String sql = "SELECT d.deck_id, d.title, d.description, d.deck_type, d.position_id, p.position_name "
                + "FROM dbo.FlashcardDecks d LEFT JOIN dbo.Positions p ON p.position_id = d.position_id "
                + "WHERE d.deck_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapDeck(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the tai bo Flashcard " + deckId, e);
        }
    }

    public List<Flashcard> getCardsByDeckId(int deckId) {
        List<Flashcard> list = new ArrayList<>();
        String sql = "SELECT card_id, deck_id, question, answer FROM dbo.Flashcards WHERE deck_id = ? ORDER BY card_id";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Flashcard c = new Flashcard();
                    c.setCardId(rs.getInt("card_id"));
                    c.setDeckId(rs.getInt("deck_id"));
                    c.setQuestion(rs.getString("question"));
                    c.setAnswer(rs.getString("answer"));
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the tai Flashcard cua bo de " + deckId, e);
        }
        return list;
    }

    public boolean isActiveMentor(int userId) {
        String sql = "SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.MentorAssignments "
                + "WHERE mentor_id = ? AND status = 'ACTIVE') THEN 1 ELSE 0 END";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the kiem tra quyen quan ly bo Flashcard", e);
        }
    }

    public int createDeck(String title, String description, String type, Integer positionId) {
        String sql = "INSERT INTO dbo.FlashcardDecks (title, description, deck_type, position_id) "
                + "OUTPUT INSERTED.deck_id VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, type);
            setNullableInt(ps, 4, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the tao bo Flashcard", e);
        }
    }

    public boolean updateDeck(int deckId, String title, String description, Integer positionId) {
        String sql = "UPDATE dbo.FlashcardDecks SET title = ?, description = ?, position_id = ? WHERE deck_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            setNullableInt(ps, 3, positionId);
            ps.setInt(4, deckId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the cap nhat bo Flashcard", e);
        }
    }

    public boolean deleteDeck(int deckId) {
        String sql = "DELETE FROM dbo.FlashcardDecks WHERE deck_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the xoa bo Flashcard", e);
        }
    }

    public boolean createCard(int deckId, String question, String answer) {
        String sql = "INSERT INTO dbo.Flashcards (deck_id, question, answer) VALUES (?, ?, ?)";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            ps.setString(2, question);
            ps.setString(3, answer);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the them the Flashcard", e);
        }
    }

    public boolean updateCard(int cardId, int deckId, String question, String answer) {
        String sql = "UPDATE dbo.Flashcards SET question = ?, answer = ? WHERE card_id = ? AND deck_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, question);
            ps.setString(2, answer);
            ps.setInt(3, cardId);
            ps.setInt(4, deckId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the cap nhat the Flashcard", e);
        }
    }

    public boolean deleteCard(int cardId, int deckId) {
        String sql = "DELETE FROM dbo.Flashcards WHERE card_id = ? AND deck_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cardId);
            ps.setInt(2, deckId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the xoa the Flashcard", e);
        }
    }

    private FlashcardDeck mapDeck(ResultSet rs) throws SQLException {
        FlashcardDeck d = new FlashcardDeck();
        d.setDeckId(rs.getInt("deck_id"));
        d.setTitle(rs.getString("title"));
        d.setDescription(rs.getString("description"));
        d.setType(rs.getString("deck_type"));
        d.setPositionId((Integer) rs.getObject("position_id"));
        d.setPositionName(rs.getString("position_name"));
        return d;
    }

    private void setNullableInt(PreparedStatement ps, int parameterIndex, Integer value) throws SQLException {
        if (value == null || value <= 0) {
            ps.setNull(parameterIndex, Types.INTEGER);
        } else {
            ps.setInt(parameterIndex, value);
        }
    }
}
