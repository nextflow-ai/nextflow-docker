#!/bin/bash
# ============================================================================
# NEXTFLOW GITLAB INITIALIZATION
# ============================================================================
# Mô tả: Khởi tạo GitLab cho NextFlow CRM-AI
# Chức năng: Tạo projects và cấu hình cơ bản
# ============================================================================

set -e

# Logging functions
log_info() {
    echo "[GITLAB-INIT] $1"
}

log_success() {
    echo "[GITLAB-INIT] ✅ $1"
}

log_warning() {
    echo "[GITLAB-INIT] ⚠️  $1"
}

log_error() {
    echo "[GITLAB-INIT] ❌ $1"
}

# Đợi GitLab sẵn sàng
wait_for_gitlab() {
    log_info "Đợi GitLab khởi động..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "http://localhost:8088/-/health" >/dev/null 2>&1; then
            log_success "GitLab đã sẵn sàng!"
            return 0
        fi

        sleep 30
        attempt=$((attempt + 1))
    done

    log_warning "GitLab chưa sẵn sàng sau $max_attempts lần thử"
    return 1
}

# Cấu hình GitLab cơ bản
configure_gitlab_basic() {
    log_info "Cấu hình GitLab cơ bản..."

    gitlab-rails runner "
        # Cấu hình cơ bản
        ApplicationSetting.current.update!(
            signup_enabled: true,
            require_admin_approval_after_user_signup: false,
            send_user_confirmation_email: false,
            container_registry_enabled: true,
            auto_devops_enabled: true,
            shared_runners_enabled: true
        )
        puts 'GitLab configured successfully!'
    " 2>/dev/null || log_warning "Không thể cấu hình GitLab"
}

# Tạo NextFlow projects
create_nextflow_projects() {
    log_info "Tạo NextFlow projects..."

    gitlab-rails runner "
        # Tạo group NextFlow
        begin
            group = Group.find_or_create_by(path: 'nextflow-crm-ai') do |g|
                g.name = 'NextFlow CRM-AI'
                g.description = 'NextFlow CRM-AI Project Group'
                g.visibility_level = Gitlab::VisibilityLevel::PRIVATE
            end

            root_user = User.find_by(username: 'root')
            group.add_owner(root_user) unless group.has_owner?(root_user)

            # Tạo projects cơ bản
            projects = [
                'nextflow-backend',
                'nextflow-frontend',
                'nextflow-mobile',
                'nextflow-infrastructure'
            ]

            projects.each do |project_path|
                unless Project.find_by(path: project_path, namespace: group)
                    project = Projects::CreateService.new(
                        root_user,
                        name: project_path.titleize,
                        path: project_path,
                        namespace_id: group.id,
                        visibility_level: Gitlab::VisibilityLevel::PRIVATE,
                        initialize_with_readme: true
                    ).execute

                    puts \"Created: #{project_path}\" if project.persisted?
                end
            end

            puts 'NextFlow projects ready!'
        rescue => e
            puts \"Error: #{e.message}\"
        end
    " 2>/dev/null || log_warning "Không thể tạo projects"
}

# Main function
main() {
    log_info "🚀 Khởi tạo GitLab NextFlow..."

    # Đợi GitLab sẵn sàng
    if wait_for_gitlab; then
        # Cấu hình cơ bản
        configure_gitlab_basic

        # Tạo NextFlow projects
        create_nextflow_projects

        log_success "🎉 GitLab NextFlow đã được khởi tạo!"
    else
        log_warning "GitLab chưa sẵn sàng, bỏ qua khởi tạo"
    fi
}

# Chỉ chạy nếu được gọi trực tiếp
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
