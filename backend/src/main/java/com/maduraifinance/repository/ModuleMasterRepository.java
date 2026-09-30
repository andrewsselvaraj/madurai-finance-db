package com.maduraifinance.repository;

import com.maduraifinance.domain.ModuleMaster;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ModuleMasterRepository extends JpaRepository<ModuleMaster, String> {

    Optional<ModuleMaster> findByModuleCode(String moduleCode);
}
