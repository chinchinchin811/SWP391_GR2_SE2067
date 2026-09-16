package model;

import java.io.Serializable;

public class JobLevel implements Serializable {
    private int levelId;
    private String levelName;
    private int rankOrder;
    private String description;

    public JobLevel() {
    }

    public JobLevel(int levelId, String levelName, int rankOrder, String description) {
        this.levelId = levelId;
        this.levelName = levelName;
        this.rankOrder = rankOrder;
        this.description = description;
    }

    public int getLevelId() {
        return levelId;
    }

    public void setLevelId(int levelId) {
        this.levelId = levelId;
    }

    public String getLevelName() {
        return levelName;
    }

    public void setLevelName(String levelName) {
        this.levelName = levelName;
    }

    public int getRankOrder() {
        return rankOrder;
    }

    public void setRankOrder(int rankOrder) {
        this.rankOrder = rankOrder;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return levelName;
    }
}
